/************************************************************\
 * Copyright 2014 Lawrence Livermore National Security, LLC
 * (c.f. AUTHORS, NOTICE.LLNS, COPYING)
 *
 * This file is part of the Flux resource manager framework.
 * For details, see https://github.com/flux-framework.
 *
 * SPDX-License-Identifier: LGPL-3.0
\************************************************************/

#ifndef HAVE_LIBAGGREGATE_AGGREGATE_H
#define HAVE_LIBAGGREGATE_AGGREGATE_H 1

/*
 *  Push single json object `o` to local aggregator module via RPC.
 *   Steals the reference to `o`. If fwd_count > 0, then set local
 *   forward count in aggregator message. If `t` is non-negative,
 *   then set local forward timeout to this value.
 */
flux_future_t *aggregator_push_json (flux_t *h, int fwd_count, double t,
		                     const char *key, json_t *o);

/*  Fulfill future when aggregate at `key` is "complete", i.e.
 *   count == total. Use aggreate_wait_get_unpack () to unpack final
 *   aggregate kvs value after successful fulfillment.
 */
flux_future_t *aggregate_wait (flux_t *h, const char *key);

/*  Get final aggregate result as string
 */
int aggregate_wait_get (flux_future_t *f, const char **s);

/*  Get final aggregate JSON object using Jansson json_unpack() format:
 */
int aggregate_wait_get_unpack (flux_future_t *f, const char *fmt, ...);

/*  Unpack the aggregate fulfilled in `f` into the kvs at path.
 *   Just the aggregate `entries` object is pushed to the new location,
 *   dropping the aggregate context count, total, min, max, etc.
 *
 *  The original aggregate key is removed.
 */
int aggregate_unpack_to_kvs (flux_future_t *f, const char *path);

#endif /* !HAVE_LIBAGGREGATE_AGGREGATE_H */
