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
        idx
    ):
    if creatures.shape[0] > 1 and creatures.shape[1] > 1:
        positions = [
                (idx[0] - 1, idx[1] ),
                (idx[0] + 1, idx[1] ),
                (idx[0], idx[1] - 1),
                (idx[0], idx[1] + 1),
        ]
    elif creatures.shape[0] == 1 and creatures.shape[1] > 1:
        positions = [
                (idx[0], idx[1] - 1),
                (idx[0], idx[1] + 1),
        ]
    elif creatures.shape[0] >= 1 and creatures.shape[1] == 1:
        positions = [
                (idx[0] - 1, idx[1] ),
                (idx[0] + 1, idx[1] ),
        ]
    else:
        positions = []
    positions = [(x % creatures.shape[0], y % creatures.shape[1]) for x,y in positions]
    return positions

cdef get_free_positions(
        numpy.ndarray[numpy.int64_t, ndim=2] creatures,
        idx
    ):
    positions = get_available_positions(creatures,idx)
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

    creatures = numpy.where((creatures > 0) & (creatures <= age_fish), creatures +1, creatures)
    creatures = numpy.where((creatures < 0) & (creatures >= -age_shark), creatures -1, creatures)

    # move fish
    for idx in zip(*numpy.nonzero(creatures > 0)):
        positions = get_free_positions(creatures,idx)
        if len(positions) > 0:
            p = positions[rand() % (len(positions))]
            creatures[p[0], p[1]] = creatures[idx[0], idx[1]]
            creatures[idx[0], idx[1]] = 0

    # reproduce fish
    for idx in zip(*numpy.nonzero(creatures > age_fish)):
        positions = get_free_positions(creatures,idx)
        if len(positions) > 0:
            p = positions[rand() % (len(positions))]
            creatures[p[0], p[1]] = 1
            creatures[idx[0], idx[1]] = 1

    # reproduce shark
    for idx in zip(*numpy.nonzero(creatures < -age_shark)):
        positions = get_free_positions(creatures,idx)
        if len(positions) > 0:
            p = positions[rand() % (len(positions))]
            creatures[p[0], p[1]] = -1
            creatures[idx[0], idx[1]] = -1
            energies[idx[0], idx[1]] = energies[p[0], p[1]]

    # move shark
    for idx in zip(*numpy.nonzero(creatures < 0)):
        positions = get_available_positions(creatures,idx)
        fish_positions = [(x,y) for x,y in positions if creatures[x,y] > 0]
        empty_positions = [(x,y) for x,y in positions if creatures[x,y] == 0]
        if len(fish_positions) > 0:
            p = fish_positions[rand() % (len(fish_positions))]
            creatures[p[0], p[1]] = creatures[idx[0], idx[1]]
            energies[p[0], p[1]] = energies[idx[0], idx[1]] + consume_energy_gain
            creatures[idx[0], idx[1]] = 0
            energies[idx[0], idx[1]] = 0
        elif len(empty_positions) > 0:
            p = empty_positions[rand() % (len(empty_positions))]
            creatures[p[0], p[1]] = creatures[idx[0], idx[1]]
            energies[p[0], p[1]] = energies[idx[0], idx[1]]
            creatures[idx[0], idx[1]] = 0
            energies[idx[0], idx[1]] = 0

    energies_old = energies
    energies = numpy.where((energies > 0), energies -1, energies)
    for idx in zip(*numpy.nonzero((energies == 0) & (energies_old > 0))):
        creatures[idx[0], idx[1]] = 0

    return (creatures, energies)
