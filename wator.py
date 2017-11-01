import numpy

from random import randrange

class WaTor:

    def __init__(self, creatures = None, 
                       shape = None, nfish = None, nsharks = None,
                       age_fish = 5, age_shark = 10,
                       energies = None, energy_initial = None):
        self.creatures = creatures

        if isinstance(self.creatures,numpy.ndarray):
            if nfish != None or nsharks != None or shape != None:
                raise ValueError("creatures are defined, variables nfish, nsharks, shape, shouldn't be defined")
        elif self.creatures == None:
            if nfish == None or nsharks == None or shape == None:
                raise ValueError("creatures aren't defined, variables nfish, nsharks, shape, must be defined")
        else:
            raise ValueError('creatures should be None or ndarray')

        if shape != None:
            self.creatures = numpy.zeros(shape)

            count = shape[0] * shape[1]

            if count < nsharks + nfish:
                raise ValueError('Too small world for such amount of fish and sharks')

            all_points = self.creatures.view()
            all_points.shape = (count,)

            for i in range(0,count):
                r = randrange(0,count-i)

                if r < nfish:
                    all_points[i] = 1
                    nfish -= 1
                elif r < nfish + nsharks:
                    all_points[i] = -1
                    nsharks -= 1
                else:
                    all_points[i] = 0

        if isinstance(energies, numpy.ndarray):
            if energies.shape != self.creatures.shape:
                raise ValueError('energies shape must mast creatures shape')
            if energy_initial != None:
                raise ValueError('energies and energy_initial, only one must be defined')
        else:
            if energy_initial == None:
                energy_initial = 5
            energies = numpy.where(self.creatures < 0, energy_initial, 0)
        self.energies = energies

    def count_fish(self):
        return numpy.count_nonzero(self.creatures > 0)

    def count_sharks(self):
        return numpy.count_nonzero(self.creatures < 0)
