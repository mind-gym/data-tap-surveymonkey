from unittest import mock

from tap_surveymonkey import main


def test_component_discovery(tmp_path, config, capsys, catalog_discovered):
    # Givem
    # A config file with the expected keys
    config_file_path = str(tmp_path / 'config.json')

    # When
    # We run the app in discovery mode
    with mock.patch('sys.argv', ['./tap_surveymonkey/__init__.py', '-c', config_file_path, '-d']):
        main()

    # Then
    expected = catalog_discovered
    out, err = capsys.readouterr()

    assert out == expected, "expect discovered catalog"
    assert err == '', "expect empty error stream"

def test_foo(tmp_path, config, capsys, catalog_discovered):
    # Givem
    # A config file with the expected keys
    config_file_path = str(tmp_path / 'config.json')

    # When
    # We run the app in discovery mode
    command = [
        './tap_surveymonkey/__init__.py',
        '-c', config_file_path,
        '--catalog', 'fixtures/catalog-discovered.json'
    ]
    with mock.patch('sys.argv', command):
        main()

    # Then
    out, err = capsys.readouterr()

    assert out == '', "expect empty stdout"
    assert err == '', "expect empty error stream"
