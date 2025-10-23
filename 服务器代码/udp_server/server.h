#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/udp.h>
#include <stdio.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <string.h>
#include <sqlite3.h>
#include <time.h>  
#define PORT 8888
#define DBFILENAME "lockers.db"

int do_login(char *buf);
int do_register(char *buf);
int do_pickup(char *buf);
int do_delivery(char *buf);
void init_lockers();
