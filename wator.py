import numpy

from random import randrange

class WaTor:

    def __init__(self, creatures = None, 
                       shape = None, nfish = None, nsharks = None,
                       age_fish = 5, age_shark = 10,
                       energies = None, energy_initial = None,
                       consume_energy_gain = 3 ):
        self.creatures = creatures
        self.age_fish = age_fish
        self.age_shark = age_shark
        self.consume_energy_gain = 3

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
                    all_points[i] = randrange(1,age_fish)
                    nfish -= 1
                elif r < nfish + nsharks:
                    all_points[i] = - randrange(1,age_shark)
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

    def tick(self):
        creatures = self.creatures
        energies = self.energies

        creatures = numpy.where((creatures > 0) & (creatures <= self.age_fish), creatures +1, creatures)
        creatures = numpy.where((creatures < 0) & (creatures >= -self.age_shark), creatures -1, creatures)

        def get_available_positions(creatures, idx):
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

        def get_free_positions(creatures, idx):
            positions = get_available_positions(creatures,idx)
            positions = [(x,y) for x,y in positions if creatures[x,y] == 0]
            return positions


        # move fish
        for idx in zip(*numpy.nonzero(creatures > 0)):
            positions = get_free_positions(creatures,idx)
            if len(positions) > 0:
                p = positions[randrange(0,len(positions))]
                creatures[p[0], p[1]] = creatures[idx[0], idx[1]]
                creatures[idx[0], idx[1]] = 0

        # reproduce fish
        for idx in zip(*numpy.nonzero(creatures > self.age_fish)):
            positions = get_free_positions(creatures,idx)
            if len(positions) > 0:
                p = positions[randrange(0,len(positions))]
                creatures[p[0], p[1]] = 1
                creatures[idx[0], idx[1]] = 1

        # reproduce shark
        for idx in zip(*numpy.nonzero(creatures < -self.age_shark)):
            positions = get_free_positions(creatures,idx)
            if len(positions) > 0:
                p = positions[randrange(0,len(positions))]
                creatures[p[0], p[1]] = -1
                creatures[idx[0], idx[1]] = -1
                energies[idx[0], idx[1]] = energies[p[0], p[1]]

        # move shark
        for idx in zip(*numpy.nonzero(creatures < 0)):
            positions = get_available_positions(creatures,idx)
            fish_positions = [(x,y) for x,y in positions if creatures[x,y] > 0]
            empty_positions = [(x,y) for x,y in positions if creatures[x,y] == 0]
            if len(fish_positions) > 0:
                p = fish_positions[randrange(0,len(fish_positions))]
                creatures[p[0], p[1]] = creatures[idx[0], idx[1]]
                energies[p[0], p[1]] = energies[idx[0], idx[1]] + self.consume_energy_gain
                creatures[idx[0], idx[1]] = 0
                energies[idx[0], idx[1]] = 0
            elif len(empty_positions) > 0:
                p = empty_positions[randrange(0,len(empty_positions))]
                creatures[p[0], p[1]] = creatures[idx[0], idx[1]]
                energies[p[0], p[1]] = energies[idx[0], idx[1]]
                creatures[idx[0], idx[1]] = 0
                energies[idx[0], idx[1]] = 0

        energies_old = energies
        energies = numpy.where((energies > 0), energies -1, energies)
        for idx in zip(*numpy.nonzero((energies == 0) & (energies_old > 0))):
            creatures[idx[0], idx[1]] = 0

        self.creatures = creatures
        self.energies = energies

        return self
