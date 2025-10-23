#include "server.h"

#define PORT 8888
int main(int argc, const char *argv[])
{
	int fd = socket(AF_INET, SOCK_DGRAM, 0);
	if(fd < 0) {
		perror("socket");
		exit(EXIT_FAILURE);
	}
	struct sockaddr_in addr = {
		.sin_family = AF_INET,
		.sin_port = htons(PORT),
	};
	if( bind(fd, (struct sockaddr *)&addr, sizeof(addr) ) ) {
		perror("bind");
		exit(EXIT_FAILURE);
	}

	init_lockers();

	int ret;
	char buf[BUFSIZ] = {};
	struct sockaddr_in client_addr;
	socklen_t addrlen = sizeof(client_addr);
	while(1) {
		ret = recvfrom(fd, buf, BUFSIZ, 0, (struct sockaddr *)&client_addr, &addrlen);
		if(ret < 0) {
			perror("recvfrom");
			exit(EXIT_FAILURE);
		}
		printf("recv data:%s\n", buf);
		switch(buf[0]) {
		case 'l':
			ret = do_login(&buf[1]);
			break;
		case 'r':
			ret = do_register(&buf[1]);
			break;
		case 'p':
			ret = do_pickup(&buf[1]);
			break;
		case 'd':
			ret = do_delivery(&buf[1]);
			break;
		default:
			fprintf(stderr, "不存在的消息类型:%c\n", buf[0]);
		}
		sendto(fd, buf, strlen(&buf[1]) + 2, 0, 
				(struct sockaddr *)&client_addr, addrlen);
	}
	return 0;
}
