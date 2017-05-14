#include <stdio.h>  
#include <stdlib.h>  
#include <errno.h>  
#include <string.h>  
#include <x86_64-linux-gnu/sys/types.h>  
#include <netinet/in.h>  
#include <x86_64-linux-gnu/sys/socket.h>  
#include <x86_64-linux-gnu/sys/wait.h>  
#include <unistd.h>  
#include <arpa/inet.h>  
#define MAXBUF 1024  
int main(int argc, char **argv)  
{  
    int sockfd, new_fd;  
    socklen_t len;  
    FILE *stream;

    /* struct sockaddr_in my_addr, their_addr; */ // IPv4  
    struct sockaddr_in6 my_addr, their_addr; // IPv6  ,my_addr服务器地址
  
    unsigned int myport, lisnum;  
    char buf[MAXBUF + 1];  
    //argv[1]服务器端口号
    if (argv[1])  
        myport = atoi(argv[1]);  
    else  
        myport = 7838;  
  
    if (argv[2])  
        lisnum = atoi(argv[2]);  
    else  
        lisnum = 2;  
  
    /* if ((sockfd = socket(PF_INET, SOCK_STREAM, 0)) == -1) { */ // IPv4  
    if ((sockfd = socket(PF_INET6, SOCK_STREAM, 0)) == -1) { // IPv6  
        perror("socket");  
        exit(1);  
    } else  
        printf("socket created\n");  
  
    bzero(&my_addr, sizeof(my_addr));  
    /* my_addr.sin_family = PF_INET; */ // IPv4  
    my_addr.sin6_family = PF_INET6;    // IPv6  
    /* my_addr.sin_port = htons(myport); */ // IPv4  
    my_addr.sin6_port = htons(myport);   // IPv6  

    if (argv[3])
        /* my_addr.sin_addr.s_addr = inet_addr(argv[3]); */ // IPv4  
        inet_pton(AF_INET6, argv[3], &my_addr.sin6_addr);  // IPv6  
    else  
        /* my_addr.sin_addr.s_addr = INADDR_ANY; */ // IPv4  
        my_addr.sin6_addr = in6addr_any;            // IPv6  
  
    /* if (bind(sockfd, (struct sockaddr *) &my_addr, sizeof(struct sockaddr)) */ // IPv4  
    if (bind(sockfd, (struct sockaddr *) &my_addr, sizeof(struct sockaddr_in6))== -1) {
        perror("bind");  
        exit(1);  
    } else  
        printf("binded\n");  
  
    if (listen(sockfd, lisnum) == -1) {  
        perror("listen");  
        exit(1);  
    } else  
        printf("begin listen\n");  
  
    while (1) {
        len = sizeof(struct sockaddr);
        if ((new_fd = accept(sockfd, (struct sockaddr *) &their_addr, &len)) == -1) {
            perror("accept");
            exit(errno);
        } else
            printf("server: got connection from %s, port %d, socket %d\n",
                    /* inet_ntoa(their_addr.sin_addr), */ // IPv4
                   inet_ntop(AF_INET6, &their_addr.sin6_addr, buf, sizeof(buf)), // IPv6  
                    /* ntohs(their_addr.sin_port), new_fd); */ // IPv4
                   their_addr.sin6_port, new_fd); // IPv6  


        //打开文件
        if ((stream = fopen("1.mp4", "rb")) == NULL) {
            printf("The file 1.mp4 not opend!");
            exit(1);
        } else
            printf("open file:1.mp4");
        /* 开始处理每个新连接上的数据收发 */
        bzero(buf, MAXBUF);

        int lengsize = 0;
        while ((lengsize = fread(buf, 1, 1024, stream)) > 0) {
            if (send(new_fd, buf, lengsize, 0) < 0) {
                printf("send file failed!");
                break;
            }
            bzero(buf, MAXBUF);
        }

        if (fclose(stream)) {
            printf("File data not closed\n");
            exit(1);
        }
        close(new_fd);
    }
    close(sockfd);
    return 0;
}

