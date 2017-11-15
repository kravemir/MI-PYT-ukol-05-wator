import numpy
from random import randrange

def generate_creatures(shape, nfish, nsharks, age_fish, age_shark):
    creatures = numpy.zeros(shape)
    count = shape[0] * shape[1]

    if count < nsharks + nfish:
        raise ValueError('Too small world for such amount of fish and sharks')

    all_points = creatures.view()
    all_points.shape = (count,)

    for i in range(0,count):
        r = randrange(0,count-i)

        if r < nfish:
            all_points[i] = randrange(1,age_fish)
            nfish -= 1
        elif r < nfish + nsharks:
            all_points[i] = - randrange(1,age_shark)
            nsharks -= 1
        else:
            all_points[i] = 0
    return creatures
