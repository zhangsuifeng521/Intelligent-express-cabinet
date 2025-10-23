#include <stdio.h>
#include <string.h>
#include <sqlite3.h>
#include <stdlib.h>

#define DB_FILENAME "lockers.db"
#define LOCKER_COUNT 20
#define MAX_STRING_LENGTH 50

// 函数声明
void print_html_header();
void print_html_footer();
void print_page_body();

void generate_status_section();
void generate_records_section(); 
void generate_couriers_section();

int execute_sql_query(const char *sql, void (*row_processor)(sqlite3_stmt*, void*), void *user_data);
void process_status_row(sqlite3_stmt *stmt, void *user_data);
void process_records_row(sqlite3_stmt *stmt, void *user_data);
void process_couriers_row(sqlite3_stmt *stmt, void *user_data);

// 数据结构定义
typedef struct {
    char values[LOCKER_COUNT][MAX_STRING_LENGTH];
    int status[LOCKER_COUNT];
} LockerData;

int main(void) {
    print_html_header();
    print_page_body();
    print_html_footer();
    return 0;
}

void print_html_header() {
    printf("Content-Type: text/html; charset=UTF-8\n\n");
    printf("<!DOCTYPE html>\n");
    printf("<html lang=\"zh\">\n");
    printf("<head>\n");
    printf("    <meta charset=\"UTF-8\">\n");
    printf("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n");
    printf("    <title>快递柜管理</title>\n");
    printf("    <link rel=\"stylesheet\" href=\"/styles.css\">\n");
    printf("</head>\n");
    printf("<body>\n");
}

void print_html_footer() {
    printf("</body>\n");
    printf("</html>\n");
}

void print_page_body() {
    printf("<div id=\"header\">\n");
    printf("  <h1>快递柜管理员后台</h1>\n");
    printf("</div>\n");

    // 选项卡导航
    printf("<div class=\"tabs\">\n");
    printf("  <button class=\"tab-button active\" onclick=\"openTab('status-tab')\">快递柜状态</button>\n");
    printf("  <button class=\"tab-button\" onclick=\"openTab('records-tab')\">投递记录</button>\n");
    printf("  <button class=\"tab-button\" onclick=\"openTab('couriers-tab')\">快递员信息</button>\n");
    printf("</div>\n");

    // 选项卡内容
    printf("<div id=\"status-tab\" class=\"tab-content active\">\n");
    generate_status_section();
    printf("</div>\n");

    printf("<div id=\"records-tab\" class=\"tab-content\">\n");
    generate_records_section();
    printf("</div>\n");

    printf("<div id=\"couriers-tab\" class=\"tab-content\">\n");
    generate_couriers_section();
    printf("</div>\n");

    // JavaScript 代码
    printf("<script>\n");
    printf("function openTab(tabName) {\n");
    printf("  // 隐藏所有选项卡内容\n");
    printf("  var tabContents = document.getElementsByClassName('tab-content');\n");
    printf("  for (var i = 0; i < tabContents.length; i++) {\n");
    printf("    tabContents[i].classList.remove('active');\n");
    printf("  }\n");
    printf("  \n");
    printf("  // 移除所有按钮的激活状态\n");
    printf("  var tabButtons = document.getElementsByClassName('tab-button');\n");
    printf("  for (var i = 0; i < tabButtons.length; i++) {\n");
    printf("    tabButtons[i].classList.remove('active');\n");
    printf("  }\n");
    printf("  \n");
    printf("  // 显示选中的选项卡内容并激活对应的按钮\n");
    printf("  document.getElementById(tabName).classList.add('active');\n");
    printf("  event.currentTarget.classList.add('active');\n");
    printf("}\n");
    printf("</script>\n");
}

void generate_status_section() {
    LockerData locker_data = {0};
    
    const char *sql = "SELECT * FROM lockers";
    if (execute_sql_query(sql, process_status_row, &locker_data) != 0) {
        fprintf(stderr, "获取快递柜状态失败\n");
        return;
    }

    printf("<div class=\"section\">\n");
    printf("    <table id=\"locker-status\">\n");
    printf("        <tbody>\n");
    printf("            <tr><th colspan=\"3\">快递柜状态</th></tr>\n");

    const char *status_classes[] = {
        "status-free",    // 空闲
        "status-occupied", // 占用  
        "status-use",     // 使用
        "status-damaged", // 故障
        "status-err"      // 异常
    };
    
    const char *size_classes[] = {
        "large", "medium", "small", "small", "small", 
        "small", "small", "medium", "medium", "medium"
    };

    printf("            <tr>\n");
    printf("                <td class=\"%s %s\">01 %s</td>\n", 
           status_classes[locker_data.status[0]], size_classes[0], locker_data.values[0]);
    printf("                <td rowspan=\"10\" id=\"wireway\"></td>\n");
    printf("                <td class=\"%s %s\">11 %s</td>\n", 
           status_classes[locker_data.status[10]], size_classes[0], locker_data.values[10]);
    printf("            </tr>\n");

    for(int i = 1; i < 10; i++) {
        printf("            <tr>\n");
        printf("                <td class=\"%s %s\">%02d %s</td>\n", 
               status_classes[locker_data.status[i]], size_classes[i], i+1, locker_data.values[i]);
        printf("                <td class=\"%s %s\">%02d %s</td>\n", 
               status_classes[locker_data.status[i+10]], size_classes[i], i+11, locker_data.values[i+10]);
        printf("            </tr>\n");
    }
    
    printf("            <tr><td colspan=\"3\"></td></tr>\n");
    printf("        </tbody>\n");
    printf("    </table>\n");
    printf("</div>\n");
}

void generate_records_section() {
    printf("<div class=\"section\">\n");
    printf("   <table class=\"data-table\">\n");
    printf("  <thead>\n");
    printf("    <tr>\n");
    printf("      <th colspan=\"9\">投递记录</th>\n");
    printf("    </tr>\n");
    printf("    <tr>\n");
    printf("      <th>记录编号</th>\n");
    printf("      <th>快递包裹号</th>\n");
    printf("      <th>快递员手机号</th>\n");
    printf("      <th>快递公司</th>\n");
    printf("      <th>投递时间</th>\n");
    printf("      <th>收件人手机号</th>\n");
    printf("      <th>取件码</th>\n");
    printf("      <th>取件时间</th>\n");
    printf("      <th>取件方式</th>\n");
    printf("    </tr>\n");
    printf("  </thead>\n");
    printf("    <tbody>\n");
    
    const char *sql = "SELECT * FROM records";
    execute_sql_query(sql, process_records_row, NULL);
    
    printf("    </tbody>\n");
    printf("  </table>\n");
    printf("</div>\n");
}

void generate_couriers_section() {
    printf("<div class=\"section\">\n");
    printf("   <table class=\"data-table\">\n");
    printf("  <thead>\n");
    printf("    <tr>\n");
    printf("      <th colspan=\"4\">快递员信息</th>\n");
    printf("    </tr>\n");
    printf("    <tr>\n");
    printf("      <th>ID</th>\n");
    printf("      <th>手机号</th>\n");
    printf("      <th>密码</th>\n");
    printf("      <th>公司</th>\n");
    printf("    </tr>\n");
    printf("  </thead>\n");
    printf("    <tbody>\n");
    
    const char *sql = "SELECT * FROM couriers";
    execute_sql_query(sql, process_couriers_row, NULL);
    
    printf("    </tbody>\n");
    printf("  </table>\n");
    printf("</div>\n");
}

// 通用的SQL查询执行函数
int execute_sql_query(const char *sql, void (*row_processor)(sqlite3_stmt*, void*), void *user_data) {
    sqlite3 *db = NULL;
    sqlite3_stmt *stmt = NULL;
    int rc;
    
    rc = sqlite3_open(DB_FILENAME, &db);
    if (rc != SQLITE_OK) {
        fprintf(stderr, "无法打开数据库: %s\n", sqlite3_errmsg(db));
        return -1;
    }
    
    rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    if (rc != SQLITE_OK) {
        fprintf(stderr, "SQL准备失败: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return -1;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        if (row_processor) {
            row_processor(stmt, user_data);
        }
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return 0;
}

void process_status_row(sqlite3_stmt *stmt, void *user_data) {
    LockerData *locker_data = (LockerData*)user_data;
    static int index = 0;
    
    if (index >= LOCKER_COUNT) return;
    
    const char *status_text = (const char*)sqlite3_column_text(stmt, 1);
    if (status_text) {
        strncpy(locker_data->values[index], status_text, MAX_STRING_LENGTH - 1);
        locker_data->values[index][MAX_STRING_LENGTH - 1] = '\0';
        
        if (strcmp(status_text, "空闲") == 0) {
            locker_data->status[index] = 0;
        } else if (strcmp(status_text, "占用") == 0) {
            locker_data->status[index] = 1;
        } else if (strcmp(status_text, "使用") == 0) {
            locker_data->status[index] = 2;
        } else if (strcmp(status_text, "故障") == 0) {
            locker_data->status[index] = 3;
        } else {
            locker_data->status[index] = 4;
        }
    } else {
        strcpy(locker_data->values[index], "未知");
        locker_data->status[index] = 4;
    }
    
    index++;
}

void process_records_row(sqlite3_stmt *stmt, void *user_data) {
    printf("    <tr>\n");
    for (int i = 0; i < 9; i++) {
        const char *value = (const char*)sqlite3_column_text(stmt, i);
        printf("      <td>%s</td>\n", value ? value : "-");
    }
    printf("    </tr>\n");
}

void process_couriers_row(sqlite3_stmt *stmt, void *user_data) {
    printf("    <tr>\n");
    for (int i = 0; i < 4; i++) {
        const char *value = (const char*)sqlite3_column_text(stmt, i);
        printf("      <td>%s</td>\n", value ? value : "-");
    }
    printf("    </tr>\n");
}