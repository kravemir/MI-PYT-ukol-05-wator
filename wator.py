import numpy

from random import randrange

from wator_natives import generate_creatures, tick_world

class WaTor:

    def __init__(self, creatures = None, 
                       shape = None, nfish = None, nsharks = None,
                       age_fish = 5, age_shark = 10,
                       energies = None, energy_initial = None,
                       energy_eat = 3 ):
        self.creatures = creatures
        self.age_fish = age_fish
        self.age_shark = age_shark
        self.consume_energy_gain = energy_eat

        if isinstance(self.creatures,numpy.ndarray):
            if nfish != None or nsharks != None or shape != None:
                raise ValueError("creatures are defined, variables nfish, nsharks, shape, shouldn't be defined")
        elif self.creatures == None:
            if nfish == None or nsharks == None or shape == None:
                raise ValueError("creatures aren't defined, variables nfish, nsharks, shape, must be defined")
        else:
            raise ValueError('creatures should be None or ndarray')

        if shape != None:
            self.creatures = generate_creatures(shape, nfish, nsharks, age_fish, age_shark)
        else:
            self.creatures = self.creatures.astype('int64')

        if isinstance(energies, numpy.ndarray):
            if energies.shape != self.creatures.shape:
                raise ValueError('energies shape must mast creatures shape')
            if energy_initial != None:
                raise ValueError('energies and energy_initial, only one must be defined')
        else:
            if energy_initial == None:
                energy_initial = 5
            energies = numpy.where(self.creatures < 0, energy_initial, 0)
        self.energies = energies.astype('int64')

    def count_fish(self):
        return numpy.count_nonzero(self.creatures > 0)

    def count_sharks(self):
        return numpy.count_nonzero(self.creatures < 0)

    def tick(self):
        self.creatures, self.energies = tick_world(
                self.creatures,
                self.energies,
                self.age_fish,
                self.age_shark,
                self.consume_energy_gain
        )
        return self
