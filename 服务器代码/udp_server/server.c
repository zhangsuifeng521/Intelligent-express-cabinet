#include "server.h"


//解决并发问题：
// struct {
// 	char number[32];
// 	char company[32];
// } courier;

int do_login(char *buf) {
	char *number = buf;
	char *passwd = buf + strlen(buf) + 1;
	printf("number:%s\n", number);
	//strcpy(courier.number, number);
	printf("passwd:%s\n", passwd);

	sqlite3 *db;
	int rc = sqlite3_open(DBFILENAME, &db);
	if (rc != SQLITE_OK) {
		fprintf(stderr, "无法打开数据库：%s\n", sqlite3_errmsg(db));
		exit(EXIT_FAILURE);
	}

	char *sql = "SELECT * FROM couriers WHERE courier_phone = ? AND password = ? ;";
	sqlite3_stmt *stmt;

	if (sqlite3_prepare_v2(db, sql, -1, &stmt, 0) != SQLITE_OK) {
		fprintf(stderr, "无法准备声明：%s\n", sqlite3_errmsg(db));
		sqlite3_close(db);
		exit(EXIT_FAILURE);
	}
	sqlite3_bind_text(stmt, 1, number, -1, SQLITE_STATIC);
	sqlite3_bind_text(stmt, 2, passwd, -1, SQLITE_STATIC);

	rc = sqlite3_step(stmt);
	if (rc != SQLITE_ROW) {
		fprintf(stderr, "登录失败：%s\n", sqlite3_errmsg(db));
		sqlite3_close(db);
		strcpy(buf, "手机号或密码不正确");
		//清理statement 防止内存泄漏
		sqlite3_finalize(stmt);
		return -1;
	}

	//strcpy(courier.company, (char *)sqlite3_column_text(stmt, 3) );
	//printf("登录成功， 快递员属于 %s \n", courier.company );

	//清理statement 防止内存泄漏
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	strcpy(buf, "ok");
	return 0;
}

int do_register(char *buf) {
	char *number = buf;
	char *passwd = buf + strlen(buf) + 1;
	char *company = passwd + strlen(passwd) + 1;
	printf("number:%s\n", number);
	printf("passwd:%s\n", passwd);
	printf("company:%s\n", company);

	sqlite3 *db;
	int rc = sqlite3_open(DBFILENAME, &db);
	if (rc != SQLITE_OK) {
		fprintf(stderr, "无法打开数据库：%s\n", sqlite3_errmsg(db));
		exit(EXIT_FAILURE);
	}

	//准备sql语句
	//占位符？ 防止SQL注入
	char *sql = "INSERT INTO couriers (courier_phone, password, delivery_company) "
		"VALUES (?, ?, ?);";
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(db, sql, -1, &stmt, 0) != SQLITE_OK) {
		fprintf(stderr, "无法准备声明：%s\n", sqlite3_errmsg(db));
		sqlite3_close(db);
		exit(EXIT_FAILURE);
	}
	sqlite3_bind_text(stmt, 1, number, -1, SQLITE_STATIC);
	sqlite3_bind_text(stmt, 2, passwd, -1, SQLITE_STATIC);
	sqlite3_bind_text(stmt, 3, company, -1, SQLITE_STATIC);

	rc = sqlite3_step(stmt);
	if (rc != SQLITE_DONE) {
		fprintf(stderr, "插入语句失败：%s\n", sqlite3_errmsg(db));
		sqlite3_close(db);
		strcpy(buf, "注册失败，手机号已注册");
		//清理statement 防止内存泄漏
		sqlite3_finalize(stmt);
		return -1;
	}
	//清理statement 防止内存泄漏
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	strcpy(buf, "注册成功！！");
	return 0;
}

int do_pickup(char *buf) {
	//查询取件码是否正确
	sqlite3 *db;
	char *pickup_code = buf;
	//打开数据库
	int rc = sqlite3_open(DBFILENAME, &db);
	if (rc != SQLITE_OK) {
		sprintf(buf, "无法打开数据库：%s", sqlite3_errmsg(db));
		printf("%s\n", buf);
	}

	sqlite3_stmt *stmt;
	char *sql = "SELECT * FROM lockers WHERE pickup_code = ?";
	if (sqlite3_prepare_v2(db, sql, -1, &stmt, 0) != SQLITE_OK) {
		sprintf(buf, "查询语句错误：%s", sqlite3_errmsg(db));
		printf("%s\n", buf);
		sqlite3_close(db);
		return -1;
	}
	//绑定参数， SQLITE_TRANSIENT表示让 SQLite3 在内部为pickup_code 创建一个副本
	sqlite3_bind_text(stmt, 1, pickup_code, -1, SQLITE_TRANSIENT);
	rc = sqlite3_step(stmt);
	if(rc != SQLITE_ROW) {
		sprintf(buf, "查询失败,取件码错误！");
		printf("%s\n", buf);
		sqlite3_close(db);
		sqlite3_finalize(stmt);
		return -1;
	}
	
	int locker_id = sqlite3_column_int(stmt, 0);
	printf("查询到柜子编号为%d 是取件码 %s 的快递\n", locker_id, pickup_code);
	sqlite3_finalize(stmt);

	//取出快递
	sql = sqlite3_mprintf("UPDATE records SET pickup_method = '取件码取件', "
			"pickup_time = datetime('now', 'localtime') "
			"WHERE pickup_code = %Q", pickup_code);
	char *err_msg = NULL;
	rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
	if (rc != SQLITE_OK) {
		//printf("查询失败：%s\n", err_msg);
		sprintf(buf, "取件失败，无效取件码\n");
		printf("%s\n", buf);
		sqlite3_free(err_msg);
		sqlite3_free(sql);
		return -1;
	}

	printf("包裹提取成功\n");
	sqlite3_free(err_msg);
	sqlite3_free(sql);
	sprintf(buf, "%d", locker_id);
	sqlite3_close(db);
	return 0;
}

// 投递功能
int do_delivery(char *buf) {
    // -------------------------- 步骤1：解析请求（扩展格式：含快递员手机号）--------------------------
    char size_code = buf[0];  // 0=小,1=中,2=大
    char *package_no = buf + 1;                     // 快递号（唯一标识，触发重复投递校验）
    char *recipient_phone = package_no + strlen(package_no) + 1;  // 收件人手机号
    char *courier_phone = recipient_phone + strlen(recipient_phone) + 1;  // 快递员手机号（新增）
    char *size_str;

    // 基础校验：快递员手机号/快递号不能为空
    if(strlen(courier_phone) == 0 || strlen(package_no) == 0) {
        strcpy(buf, "请先登录再投递或填写快递号");
        return -1;
    }

    // 尺寸转换
    switch(size_code) {
        case '0': size_str = "小"; break;
        case '1': size_str = "中"; break;
        case '2': size_str = "大"; break;
        default: 
            strcpy(buf, "无效的柜子尺寸");
            return -1;
    }
    printf("投递请求：尺寸=%s, 快递号=%s, 收件人=%s, 快递员=%s\n", 
           size_str, package_no, recipient_phone, courier_phone);

    // -------------------------- 步骤2：打开数据库 --------------------------
    sqlite3 *db;
    int rc = sqlite3_open(DBFILENAME, &db);
    if (rc != SQLITE_OK) {
        fprintf(stderr, "无法打开数据库：%s\n", sqlite3_errmsg(db));
        exit(EXIT_FAILURE);
    }

    // -------------------------- 步骤3：查询快递员所属公司（替代全局变量）--------------------------
    char *company = NULL;
    sqlite3_stmt *stmt;
    char *sql = "SELECT delivery_company FROM couriers WHERE courier_phone = ?;";
    if(sqlite3_prepare_v2(db, sql, -1, &stmt, 0) != SQLITE_OK) {
        fprintf(stderr, "SQL编译失败（查公司）：%s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return -1;
    }
    sqlite3_bind_text(stmt, 1, courier_phone, -1, SQLITE_STATIC);
    rc = sqlite3_step(stmt);
    if(rc != SQLITE_ROW) {  // 快递员未注册
        strcpy(buf, "快递员未注册，请先注册");
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return -1;
    }
    company = strdup((char *)sqlite3_column_text(stmt, 0));  // 分配内存存储公司信息
    sqlite3_finalize(stmt);

    // -------------------------- 步骤4：查询对应尺寸的空闲柜子 --------------------------
    sql = "SELECT id FROM lockers WHERE status = '空闲' AND size = ? LIMIT 1;";
    if(sqlite3_prepare_v2(db, sql, -1, &stmt, 0) != SQLITE_OK) {
        fprintf(stderr, "SQL编译失败（查柜子）：%s\n", sqlite3_errmsg(db));
        free(company);  // 释放内存，避免泄漏
        sqlite3_close(db);
        return -1;
    }
    sqlite3_bind_text(stmt, 1, size_str, -1, SQLITE_STATIC);
    rc = sqlite3_step(stmt);
    if(rc != SQLITE_ROW) {  // 无空闲柜子
        strcpy(buf, "没有找到合适的空闲柜子");
        free(company);
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return -1;
    }
    int locker_id = sqlite3_column_int(stmt, 0);
    sqlite3_finalize(stmt);

    // -------------------------- 步骤5：生成8位取件码 --------------------------
    srand(time(NULL));
    int code = rand() % 90000000 + 10000000;
    char pickup_code[9];
    sprintf(pickup_code, "%08d", code);

    // -------------------------- 步骤6：更新柜子信息（核心：重复投递校验在这里触发）--------------------------
    sql = "UPDATE lockers SET "
          "status = '使用', "
          "package_no = ?, "  // 关键：package_no是UNIQUE字段，重复会触发约束错误
          "courier_phone = ?, "
          "delivery_company = ?, "
          "delivery_time = datetime('now', 'localtime'), "
          "recipient_phone = ?, "
          "pickup_code = ? "
          "WHERE id = ?;";
    if(sqlite3_prepare_v2(db, sql, -1, &stmt, 0) != SQLITE_OK) {
        fprintf(stderr, "SQL编译失败（更柜子）：%s\n", sqlite3_errmsg(db));
        free(company);
        sqlite3_close(db);
        return -1;
    }

    // 绑定参数
    sqlite3_bind_text(stmt, 1, package_no, -1, SQLITE_STATIC);  // 唯一约束字段
    sqlite3_bind_text(stmt, 2, courier_phone, -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 3, company, -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 4, recipient_phone, -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 5, pickup_code, -1, SQLITE_STATIC);
    sqlite3_bind_int(stmt, 6, locker_id);

    // 执行更新：重复投递的错误在这里触发
    rc = sqlite3_step(stmt);
	if (rc != SQLITE_DONE) {
		fprintf(stderr, "更新柜子的状态失败:%s\n", sqlite3_errmsg(db));
		// 判断是否是唯一约束错误（重复投递）
		if (sqlite3_errcode(db) == SQLITE_CONSTRAINT_UNIQUE) {
			strcpy(buf, "请不要重复投递");
		} else {
			// 其他错误（如语法错误、权限不足）
			strcpy(buf, "投递失败，请稍后重试");
		}
		sqlite3_finalize(stmt); // 清理资源，防止内存泄漏
		sqlite3_close(db);
		free(company);   // 释放之前strdup的内存
		return -1;
	}
    if (rc != SQLITE_DONE) {
        // 核心原因：package_no是UNIQUE，同一快递号再次投递会触发SQLITE_CONSTRAINT，导致rc≠SQLITE_DONE
        fprintf(stderr, "更新柜子的状态失败:%s\n", sqlite3_errmsg(db));  // 调试用：打印具体错误（如"UNIQUE constraint failed: lockers.package_no"）
        strcpy(buf, "请不要重复投递");  // 你的业务提示，贴合用户认知
        sqlite3_finalize(stmt);  
        sqlite3_close(db);
        free(company); 
        return -1;
    }

    // -------------------------- 步骤7：清理资源并返回 --------------------------
    printf("投递成功：柜子编号=%d, 快递员公司=%s, 取件码=%s\n", locker_id, company, pickup_code);
    free(company);  // 释放内存
    sqlite3_finalize(stmt);
    sqlite3_close(db);

    // 返回柜子编号给客户端
    sprintf(buf, "%d", locker_id);
    return 0;
}
void init_lockers() {
	sqlite3 *db;
	char *err_msg = NULL;
	FILE *fp = fopen(DBFILENAME, "r");
	if(fp != NULL) {
		printf("数据库文件已存在, 无需创建.\n");
		fclose(fp);
		return;
	}

	int rc = sqlite3_open(DBFILENAME, &db);
	if (rc != SQLITE_OK) {
		fprintf(stderr, "无法打开数据库：%s\n", sqlite3_errmsg(db));
		exit(EXIT_FAILURE);
	}

	//创建快递柜状态表
	char *sql = "CREATE TABLE lockers ("
		"id INTEGER PRIMARY KEY,"  //柜子编号
		"status TEXT CHECK(status IN ('占用', '使用', '空闲', '故障')) NOT NULL," //柜子状态
		"size TEXT CHECK(size IN ('大', '中', '小')) NOT NULL,"           //柜子的尺寸
		"package_no TEXT UNIQUE,"  //包裹号
		"courier_phone TEXT,"      //快递员手机号
		"delivery_company TEXT,"   //快递公司信息
		"delivery_time TEXT,"      //投递时间
		"recipient_phone TEXT,"     //收件人手机号
		"pickup_code TEXT"
		");";
	rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
	if(rc != SQLITE_OK) {
		fprintf(stderr, "创建表 lockers 失败：%s\n", sqlite3_errmsg(db));
		sqlite3_free(err_msg);
		exit(EXIT_FAILURE);
	} else {
		printf("表 lockers 创建成功\n");
	}

	//初始化 lockers 
	sql = "BEGIN TRANSACTION;";
	sqlite3_exec(db, sql, 0, 0, &err_msg);
	for(int i = 1; i < 21; i++) {
		switch(i) {
		case 1:
		case 11:
			sql ="INSERT INTO lockers (status, size) VALUES('空闲', '大');";
			break;
		case 2:
			sql ="INSERT INTO lockers (status, size) VALUES('空闲', '中');";
			break;
		case 12:
			sql ="INSERT INTO lockers (status, size) VALUES('占用', '中');";
			break;
		case 8:
		case 9:
		case 10:
		case 18:
		case 19:
		case 20:
			sql ="INSERT INTO lockers (status, size) VALUES('空闲', '中');";
			break;
		default:
			sql ="INSERT INTO lockers (status, size) VALUES('空闲', '小');";
		}
		rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
		if (rc != SQLITE_OK) {
			fprintf(stderr, "插入数据 失败：%s\n", sqlite3_errmsg(db));
			sqlite3_free(err_msg);
			sqlite3_exec(db, "ROLLBACK;", NULL, NULL, &err_msg);
			sqlite3_close(db);
			exit(EXIT_FAILURE);
		}
	}
	sql = "COMMIT;";
	rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
	if (rc != SQLITE_OK) {
		fprintf(stderr, "事务提交 失败：%s\n", sqlite3_errmsg(db));
		sqlite3_free(err_msg);
		sqlite3_exec(db, "ROLLBACK;", NULL, NULL, &err_msg);
		sqlite3_close(db);
		exit(EXIT_FAILURE);
	} else {
		printf("成功插入20条数据\n");
	}
	//创建快递员登记表
	sql = "CREATE TABLE couriers ("
		"id INTEGER PRIMARY KEY AUTOINCREMENT,"
		"courier_phone TEXT UNIQUE,"
		"password TEXT,"
		"delivery_company TEXT"
		");";
	rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
	if (rc != SQLITE_OK) {
		fprintf(stderr, "创建快递员登记表 失败：%s\n", sqlite3_errmsg(db));
		sqlite3_free(err_msg);
		sqlite3_close(db);
		exit(EXIT_FAILURE);
	}

	//创建投递记录表
	sql = "CREATE TABLE records ("
		"id INTEGER PRIMARY KEY AUTOINCREMENT,"     //记录编号
		"package_no TEXT,"         //包裹号
		"courier_phone TEXT,"      //快递员手机号
		"delivery_company TEXT,"   //快递公司信息
		"delivery_time TEXT,"      //投递时间
		"recipient_phone TEXT,"    //收件人手机号
		"pickup_code TEXT,"        //取件码  
		"pickup_time TEXT,"        //取件时间
		"pickup_method TEXT CHECK(pickup_method IN ('快递员回收', '管理员开柜', '取件码取件'))"
		");";
	rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
	if (rc != SQLITE_OK) {
		fprintf(stderr, "创建投递记录表 失败：%s\n", sqlite3_errmsg(db));
		sqlite3_free(err_msg);
		sqlite3_close(db);
		exit(EXIT_FAILURE);
	}

	sql = "CREATE TRIGGER update_records "
		"AFTER UPDATE ON lockers FOR EACH ROW "
		"BEGIN "
			"INSERT INTO records (package_no, courier_phone, delivery_company, "
			"delivery_time, recipient_phone, pickup_code) "
			"SELECT NEW.package_no, NEW.courier_phone, NEW.delivery_company, "
			"NEW.delivery_time, NEW.recipient_phone, NEW.pickup_code "
			"WHERE NEW.package_no IS NOT NULL;"
		"END;";
	rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
	if (rc != SQLITE_OK) {
		fprintf(stderr, "触发器 update_records 创建 失败：%s\n", sqlite3_errmsg(db));
		sqlite3_free(err_msg);
		sqlite3_close(db);
		exit(EXIT_FAILURE);
	}

	sql = "CREATE TRIGGER update_lockers "
		"AFTER UPDATE OF pickup_code, pickup_method ON records FOR EACH ROW BEGIN "
		"UPDATE lockers SET package_no = NULL, courier_phone = NULL, "
		"delivery_company = NULL, delivery_time = NULL, recipient_phone = NULL, pickup_code = NULL, "
		"status = '空闲' WHERE lockers.package_no = OLD.package_no; END; ";
	rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
	if (rc != SQLITE_OK) {
		fprintf(stderr, "触发器 update_lockers 创建 失败：%s\n", sqlite3_errmsg(db));
		sqlite3_free(err_msg);
		sqlite3_close(db);
		exit(EXIT_FAILURE);
	}

	sqlite3_close(db);
}
