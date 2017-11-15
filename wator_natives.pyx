import numpy
from random import randrange

from libc.stdlib cimport rand, srand
from libc.time cimport time

cimport cython
cimport numpy

cpdef numpy.ndarray[numpy.int64_t, ndim=2] generate_creatures(
        tuple shape, int nfish, int nsharks, int age_fish, int age_shark
    ):
    cdef numpy.ndarray[numpy.int64_t, ndim=2] creatures
    cdef numpy.ndarray[numpy.int64_t, ndim=1] all_points
    cdef int count, r, i

    count = shape[0] * shape[1]
    if count < nsharks + nfish:
        raise ValueError('Too small world for such amount of fish and sharks')

    all_points = numpy.zeros( (count,), dtype='int64')

    srand(time(NULL))

    with cython.boundscheck(False):
        for i in range(0,count):
            r = rand() % (count-i)

            if r < nfish:
                all_points[i] = 1 + (rand() % (age_fish-1))
                nfish -= 1
            elif r < nfish + nsharks:
                all_points[i] = -1 - (rand() % (age_shark-1))
                nsharks -= 1
            else:
                all_points[i] = 0

    creatures = all_points.reshape(shape)
    return creatures
