#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <stdio.h>
#include <stdlib.h>

void constant(const char *name, int value)
{
	printf("  let %s = 0x%x\n", name, value);
}

int main(int argc, char **argv)
{
	printf("module Epoll = struct\n");

	constant("inp", EPOLLIN);
	constant("pri", EPOLLPRI);
	constant("out", EPOLLOUT);
	constant("rdnorm", EPOLLRDNORM);
	constant("rdband", EPOLLRDBAND);
	constant("wrnorm", EPOLLWRNORM);
	constant("wrband", EPOLLWRBAND);
	constant("msg", EPOLLMSG);
	constant("err", EPOLLERR);
	constant("hup", EPOLLHUP);
	constant("rdhup", EPOLLRDHUP);
	constant("wakeup", EPOLLWAKEUP);
	constant("oneshot", EPOLLONESHOT);
	constant("et", EPOLLET);
	/* constant("exclusive",EPOLLEXCLUSIVE); */

	printf("end\n");

	printf("module EventFD = struct\n");

	constant("cloexec", EFD_CLOEXEC);
	constant("nonblock", EFD_NONBLOCK);
	constant("semaphore", EFD_SEMAPHORE);

	printf("end\n");

	return 0;
}

/* vim: set ts=8 noet: */
