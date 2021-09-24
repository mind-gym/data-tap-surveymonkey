import json

import pytest


@pytest.fixture()
def config(tmp_path):
    config = {
        "start_date": "foo",
        "access_token": "bar"
    }

    p = tmp_path / "config.json"
    p.write_text(json.dumps(config))