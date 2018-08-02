#ifndef __RT_TIMER_H__
#define __RT_TIMER_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <time.h>

typedef struct
{
    double period;         // period of timer in seconds
    double base_period;
    int multiplier;
    unsigned long count;   // wait counter
    unsigned long abs_base_count;
    struct timespec t;     // absolute time to end of next period
} rt_timer_t;


extern int rt_timer_start(rt_timer_t *timer, struct timespec *start, int multiplier, double base_period);
extern int rt_timer_wait_rest(rt_timer_t *timer);
extern int rt_timer_get_time(struct timespec *tp);

#ifdef __cplusplus
}
#endif

#endif /* __RT_TIMER_H__ */