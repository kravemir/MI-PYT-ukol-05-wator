import numpy
from random import randrange

from libc.stdlib cimport rand, srand
from libc.time cimport time

cimport numpy

cpdef numpy.ndarray[numpy.int64_t, ndim=2] generate_creatures(
        tuple shape, int nfish, int nsharks, int age_fish, int age_shark
    ):
    cdef numpy.ndarray[numpy.int64_t, ndim=2] creatures
    cdef int count, r, i

    creatures = numpy.zeros(shape, dtype='int64')
    count = shape[0] * shape[1]

    if count < nsharks + nfish:
        raise ValueError('Too small world for such amount of fish and sharks')

    all_points = creatures.view()
    all_points.shape = (count,)

    srand(time(NULL))
    for i in range(0,count):
        r = rand() % (count-i)

        if r < nfish:
            all_points[i] = randrange(1,age_fish)
            nfish -= 1
        elif r < nfish + nsharks:
            all_points[i] = - randrange(1,age_shark)
            nsharks -= 1
        else:
            all_points[i] = 0
    return creatures
