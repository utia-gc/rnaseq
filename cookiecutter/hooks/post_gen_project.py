import logging
import os
import shutil


def make_paths(paths):
    """Make paths

    :param paths: A list of paths to be created
    :type paths: list[str]
    """
    for path in paths:
        try:
            os.makedirs(path)
        except FileExistsError:
            logging.exception("Directory %s already exists." % path)


def main():
    """Main program
    """
    dirs_to_make = [
        "data/reads/raw",
        "data/samplesheets",
        "job_logs"
    ]
    make_paths(dirs_to_make)

    decode = '{% cookiecutter.decode_samplesheet_path %}'

    shutil.copy(decode, 'data/samplesheets/decode.csv')

if __name__ == "__main__":
    main()
