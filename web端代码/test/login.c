#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ADMIN_USER "admin"
#define ADMIN_PWD  "123"
#define BUF_SIZE   256

// 解析POST数据（username=xxx&password=xxx）
void parse_post_data(char *data, char *username, char *password) {
    // 提取用户名
    char *user_start = strstr(data, "username=");
    if (user_start != NULL) {
        user_start += strlen("username=");
        char *user_end = strstr(user_start, "&");
        if (user_end != NULL) {
            strncpy(username, user_start, user_end - user_start);
        }
    }
    // 提取密码
    char *pwd_start = strstr(data, "password=");
    if (pwd_start != NULL) {
        pwd_start += strlen("password=");
        strncpy(password, pwd_start, BUF_SIZE - 1);
    }
}

int main(void) {
    // 输出HTTP响应头
    printf("Content-Type: text/html; charset=UTF-8\n\n");

    // 只接受POST方法
    char *method = getenv("REQUEST_METHOD");
    if (method == NULL || strcmp(method, "POST") != 0) {
        printf("<html><body style='background:#f0f7f7;text-align:center;padding-top:100px;'>");
        printf("<h3 style='color:#d65c5c;'>错误：请通过登录页提交数据！</h3>");
        printf("<p style='margin-top:20px;'><a href='/index.html' style='color:#11999e;'>返回登录页</a></p>");
        printf("</body></html>");
        return -1;
    }

    // 读取POST数据长度
    char *content_len_str = getenv("CONTENT_LENGTH");
    if (content_len_str == NULL) {
        printf("<html><body style='background:#f0f7f7;text-align:center;padding-top:100px;'>");
        printf("<h3 style='color:#d65c5c;'>错误：未收到登录数据！</h3>");
        printf("<p style='margin-top:20px;'><a href='/index.html' style='color:#11999e;'>返回登录页</a></p>");
        printf("</body></html>");
        return -1;
    }
    int content_len = atoi(content_len_str);
    if (content_len <= 0 || content_len > BUF_SIZE) {
        printf("<html><body style='background:#f0f7f7;text-align:center;padding-top:100px;'>");
        printf("<h3 style='color:#d65c5c;'>错误：数据长度异常！</h3>");
        printf("<p style='margin-top:20px;'><a href='/index.html' style='color:#11999e;'>返回登录页</a></p>");
        printf("</body></html>");
        return -1;
    }

    // 读取并解析POST数据
    char post_data[BUF_SIZE] = {0};
    char username[BUF_SIZE] = {0};
    char password[BUF_SIZE] = {0};
    fread(post_data, 1, content_len, stdin);
    parse_post_data(post_data, username, password);

    // 验证并跳转
    printf("<html><head>");
    printf("<meta charset='UTF-8'>");
    printf("<meta http-equiv='refresh' content='1.5; url=%s'>", 
           (strcmp(username, ADMIN_USER) == 0 && strcmp(password, ADMIN_PWD) == 0) 
           ? "/cgi-bin/home.cgi" : "/index.html");
    printf("<style>body{background:#f0f7f7;text-align:center;padding-top:100px;}h3{font-size:22px;}</style>");
    printf("</head><body>");
    if (strcmp(username, ADMIN_USER) == 0 && strcmp(password, ADMIN_PWD) == 0) {
        printf("<h3 style='color:#11999e;'>登录成功！即将进入后台...</h3>");
    } else {
        printf("<h3 style='color:#d65c5c;'>账号或密码错误！即将返回登录页...</h3>");
    }
    printf("</body></html>");

    return 0;
}