/* Allow in-tree programs to #include <flux/core.h> like out-of-tree would.
 */

#ifndef FLUX_CORE_H
#define FLUX_CORE_H

#include "src/common/libflux/flux.h"

#include "src/modules/kvs/kvs.h"
#include "src/modules/live/live.h"
#include "src/modules/barrier/barrier.h"
#include "src/modules/libjsc/jstatctl.h"
#include "src/modules/libmrpc/mrpc.h"
#include "src/modules/modctl/modctl.h"

#endif /* FLUX_CORE_H */
