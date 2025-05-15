#include "svdpi.h"

extern "C" int grey_count( int tick)
{
    return tick & (tick << 1);
}
