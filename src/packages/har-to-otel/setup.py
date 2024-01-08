#!/usr/bin/env python

import codecs
import os
from setuptools import setup, find_packages

def open_local(paths, mode="r", encoding="utf8"):
    path = os.path.join(os.path.abspath(os.path.dirname(__file__)), *paths)
    return codecs.open(path, mode, encoding)

with open_local(["requirements.txt"]) as req:
    install_requires = req.read().split("\n")

setup(name='@pname@',
    version='@version@',
    description='@desc@',
    scripts=["har-to-otel/har-to-otel.py"],
    packages=find_packages(),
    install_requires=install_requires,
)