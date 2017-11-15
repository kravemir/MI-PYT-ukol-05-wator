import numpy

from libc.stdlib cimport rand, srand
from libc.time cimport time

cimport cython
cimport numpy

cpdef numpy.ndarray[numpy.int64_t, ndim=2] generate_creatures(
        tuple shape, int nfish, int nsharks, int age_fish, int age_shark
    ):
    cdef numpy.ndarray[numpy.int64_t, ndim=2] creatures
    cdef numpy.int64_t* all_points
    cdef int count, r, i

    count = shape[0] * shape[1]
    if count < nsharks + nfish:
        raise ValueError('Too small world for such amount of fish and sharks')

    creatures = numpy.empty( shape, dtype='int64')
    all_points = <numpy.int64_t*> creatures.data

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

    return creatures

cdef get_available_positions(
        numpy.ndarray[numpy.int64_t, ndim=2] creatures,
        int x, int y
    ):
    if creatures.shape[0] > 1 and creatures.shape[1] > 1:
        positions = [
                (x - 1, y ),
                (x + 1, y ),
                (x, y - 1),
                (x, y + 1),
        ]
    elif creatures.shape[0] == 1 and creatures.shape[1] > 1:
        positions = [
                (x, y - 1),
                (x, y + 1),
        ]
    elif creatures.shape[0] >= 1 and creatures.shape[1] == 1:
        positions = [
                (x - 1, y ),
                (x + 1, y ),
        ]
    else:
        positions = []
    positions = [(x % creatures.shape[0], y % creatures.shape[1]) for x,y in positions]
    return positions

cdef get_free_positions(
        numpy.ndarray[numpy.int64_t, ndim=2] creatures,
        int x, int y
    ):
    positions = get_available_positions(creatures,x,y)
    positions = [(x,y) for x,y in positions if creatures[x,y] == 0]
    return positions

def tick_world(
        numpy.ndarray[numpy.int64_t, ndim=2] creatures,
        numpy.ndarray[numpy.int64_t, ndim=2] energies,
        int age_fish,
        int age_shark,
        int consume_energy_gain
    ):
    cdef numpy.ndarray[numpy.int64_t, ndim=2] energies_old
    cdef int x,y, px, py
    cdef long[:] xx, yy
    cdef long i

    creatures = numpy.where((creatures > 0) & (creatures <= age_fish), creatures +1, creatures)
    creatures = numpy.where((creatures < 0) & (creatures >= -age_shark), creatures -1, creatures)

    # move fish
    xx, yy = numpy.nonzero(creatures > 0)
    for i in range(len(xx)):
        x,y = xx[i], yy[i]
        positions = get_free_positions(creatures,x,y)
        if len(positions) > 0:
            px,py = positions[rand() % (len(positions))]
            creatures[px, py] = creatures[x, y]
            creatures[x, y] = 0

    # reproduce fish
    xx, yy = numpy.nonzero(creatures > age_fish)
    for i in range(len(xx)):
        x,y = xx[i], yy[i]
        positions = get_free_positions(creatures,x,y)
        if len(positions) > 0:
            px,py = positions[rand() % (len(positions))]
            creatures[px, py] = 1
            creatures[x, y] = 1

    # reproduce shark
    xx, yy = numpy.nonzero(creatures < -age_fish)
    for i in range(len(xx)):
        x,y = xx[i], yy[i]
        positions = get_free_positions(creatures,x,y)
        if len(positions) > 0:
            px,py = positions[rand() % (len(positions))]
            creatures[px, py] = -1
            creatures[x, y] = -1
            energies[x, y] = energies[px, py]

    # move shark
    xx, yy = numpy.nonzero(creatures < 0)
    for i in range(len(xx)):
        x,y = xx[i], yy[i]
        positions = get_available_positions(creatures,x,y)
        fish_positions = [(x,y) for x,y in positions if creatures[x,y] > 0]
        empty_positions = [(x,y) for x,y in positions if creatures[x,y] == 0]
        if len(fish_positions) > 0:
            px,py = fish_positions[rand() % (len(fish_positions))]
            creatures[px, py] = creatures[x, y]
            energies[px, py] = energies[x, y] + consume_energy_gain
            creatures[x, y] = 0
            energies[x, y] = 0
        elif len(empty_positions) > 0:
            px,py = empty_positions[rand() % (len(empty_positions))]
            creatures[px, py] = creatures[x, y]
            energies[px, py] = energies[x, y]
            creatures[x, y] = 0
            energies[x, y] = 0

    energies_old = energies
    energies = numpy.where((energies > 0), energies -1, energies)
    for x,y in zip(*numpy.nonzero((energies == 0) & (energies_old > 0))):
        creatures[x, y] = 0

    return (creatures, energies)
