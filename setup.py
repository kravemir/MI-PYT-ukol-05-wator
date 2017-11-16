from setuptools import setup
from Cython.Build import cythonize
import numpy

setup(
    name='wator_natives',
    ext_modules=cythonize('wator_natives.pyx', language_level=3),
    include_dirs=[numpy.get_include()],
    install_requires=[
        'Cython',
        'NumPy',
    ],
)
