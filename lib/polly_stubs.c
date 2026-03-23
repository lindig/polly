
#include <sys/epoll.h>
#include <alloca.h>
#include <sys/resource.h>
#include <unistd.h>
#include <sys/eventfd.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/alloc.h>
#include <caml/signals.h>
#include <caml/unixsupport.h>
#include <caml/threads.h>

CAMLprim value caml_polly_create1(value val_unit)
{
        CAMLparam1(val_unit);
        CAMLlocal1(val_res);
        int fd;

        if ((fd = epoll_create1(0)) == -1)
                uerror(__FUNCTION__, Nothing);

        val_res = Val_int(fd);
        CAMLreturn(val_res);
}

static value
caml_polly_ctl(value val_epfd, value val_fd, value val_events, int op)
{
        CAMLparam3(val_epfd, val_fd, val_events);
        struct epoll_event event = {
                .events = (uint32_t) Int_val(val_events),
                .data.fd = Int_val(val_fd)
        };

        int epfd_c = Int_val(val_epfd);
        int fd_c = Int_val(val_fd);
        int rc;

        caml_release_runtime_system();
        rc = epoll_ctl(epfd_c, op, fd_c, &event);
        caml_acquire_runtime_system();

        if (rc == -1)
                uerror(__FUNCTION__, Nothing);

        CAMLreturn(Val_unit);
}

CAMLprim value caml_polly_add(value val_epfd, value val_fd, value val_events)
{
        return caml_polly_ctl(val_epfd, val_fd, val_events, EPOLL_CTL_ADD);
}

CAMLprim value caml_polly_mod(value val_epfd, value val_fd, value val_events)
{
        return caml_polly_ctl(val_epfd, val_fd, val_events, EPOLL_CTL_MOD);
}

CAMLprim value caml_polly_del(value val_epfd, value val_fd, value val_events)
{
        return caml_polly_ctl(val_epfd, val_fd, val_events, EPOLL_CTL_DEL);
}

CAMLprim value
caml_polly_wait(value val_epfd, value val_max, value val_timeout, value val_f)
{
        CAMLparam4(val_epfd, val_max, val_timeout, val_f);
        CAMLlocal1(ignore);

        struct epoll_event *events;
        int ready, i;

        if (Int_val(val_max) <= 0)
                uerror(__FUNCTION__, Nothing);
        events =
            (struct epoll_event *)alloca(Int_val(val_max) *
                                         sizeof(struct epoll_event));

        int epfd_c = Int_val(val_epfd);
        int max_c = Int_val(val_max);
        int timeout_c = Int_val(val_timeout);

        caml_release_runtime_system();
        ready = epoll_wait(epfd_c, events, max_c, timeout_c);
        caml_acquire_runtime_system();

        if (ready == -1)
                uerror(__FUNCTION__, Nothing);

        for (i = 0; i < ready; i++) {
                ignore = caml_callback3(val_f,
                                        val_epfd,
                                        Val_int(events[i].data.fd),
                                        Val_int(events[i].events));
        }

        CAMLreturn(Val_int(ready));
}

CAMLprim value
caml_polly_wait_fold(value val_epfd, value val_max, value val_timeout,
                     value val_init, value val_f)
{
        CAMLparam5(val_epfd, val_max, val_timeout, val_init, val_f);
        value args[4];          /* must not be CAMLlocalN */

        /* see
         * https://github.com/ocaml/ocaml/commit/9acf32acf8843db4083c92a0200309fa51d0e4d1
         */

        struct epoll_event *events;
        int ready, i;

        if (Int_val(val_max) <= 0)
                caml_invalid_argument(__FUNCTION__);
        events =
            (struct epoll_event *)alloca(Int_val(val_max) *
                                         sizeof(struct epoll_event));

        int epfd_c = Int_val(val_epfd);
        int max_c = Int_val(val_max);
        int timeout_c = Int_val(val_timeout);

        caml_release_runtime_system();
        ready = epoll_wait(epfd_c, events, max_c, timeout_c);
        caml_acquire_runtime_system();

        if (ready == -1)
                uerror(__FUNCTION__, Nothing);

        args[0] = val_epfd;
        args[3] = val_init;
        for (i = 0; i < ready; i++) {
                args[1] = Val_int(events[i].data.fd);
                args[2] = Val_int(events[i].events);
                args[3] = caml_callbackN(val_f, 4, args);
        }

        CAMLreturn(args[3]);
}

CAMLprim value caml_polly_eventfd(value initval, value flags)
{
        CAMLparam0();

        int init_c = Int_val(initval);
        int flags_c = Int_val(flags);
        caml_release_runtime_system();
        int sock = eventfd(init_c, flags_c);
        caml_acquire_runtime_system();
        if (-1 == sock)
                uerror(__FUNCTION__, Nothing);
        CAMLreturn(Val_int(sock));
}
