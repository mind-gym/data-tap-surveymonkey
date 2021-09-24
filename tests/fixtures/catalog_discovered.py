import os

import pytest as pytest


@pytest.fixture
def catalog_discovered():

    with open('fixtures/catalog-discovered.json', 'r') as file:
        contents = file.read()

    return contents