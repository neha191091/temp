#include "rt_timer.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/resource.h>


int rt_timer_get_time(struct timespec *tp)
{
    if (clock_gettime(CLOCK_MONOTONIC, tp) < 0) {
        printf("rt_timer_get_time: error in clock_gettime\n");
        return -1;
    }
}

void rt_timer_convert_ns_to_time(struct timespec *tp)
{
    while (tp->tv_nsec >= 1e9)
    {
        tp->tv_nsec -= 1e9;
        tp->tv_sec++;
    }
    while (tp->tv_nsec < 0)
    {
        tp->tv_nsec += 1e9;
        tp->tv_sec--;
    }
}

extern int rt_timer_start(rt_timer_t *timer, struct timespec *start, int multiplier, double base_period)
{
    if (timer == NULL)
    {
        printf("no rt_timer struct\n");
        return -1;
    }

    timer->base_period = base_period;
    timer->multiplier = multiplier;
    timer->period = multiplier * base_period;
    timer->count = 0;

    timer->t.tv_sec = start->tv_sec;
    timer->t.tv_nsec = start->tv_nsec;

    timer->abs_base_count = (uint32_t)(timer->t.tv_nsec + (uint32_t)timer->t.tv_sec * (uint32_t)1e9) / (uint32_t)((double)timer->base_period * 1.0e9);

    rt_timer_wait_rest(timer);

    return 0;
}

extern int rt_timer_wait_rest(rt_timer_t *timer)
{
    if (timer == NULL)
    {
        printf("no rt_timer struct\n");
        return -1;
    }


    int skip=1;
    while(skip) {
        // add period to time to get end of period and fill up seconds
        timer->t.tv_nsec += timer->period * 1e9;
        rt_timer_convert_ns_to_time(&(timer->t));

	struct timespec cur;
	rt_timer_get_time(&cur);
	if((timer->t.tv_nsec + timer->t.tv_sec * 1e9) < (cur.tv_nsec + cur.tv_sec * 1e9)) {
		timer->count++;
		continue;
	}
	else
		skip = 0;

        // sleep until end of period in absolute time
        if (clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &(timer->t), NULL) < 0) {
            printf("rt_timer_wait_rest: error in clock_nanosleep\n");
            return -1;
        }

        timer->count++;
    }

    return 0;
}
