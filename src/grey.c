
int grey_count( int tick, int size)
{
    tick %= 1 << size;
    return tick ^ (tick >> 1);
}
