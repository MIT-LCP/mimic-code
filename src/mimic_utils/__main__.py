from argparse import ArgumentParser, RawDescriptionHelpFormatter
import logging
import sys

from mimic_utils.compare_concepts import compare_concepts
from mimic_utils.transpile import transpile_file, transpile_folder

def main():
    logging.basicConfig(
        format="%(asctime)s [%(levelname)s] %(message)s",
        level=logging.INFO
    )
    parser = ArgumentParser(description="Convert SQL to different dialects.")
    subparsers = parser.add_subparsers()

    file_parser = subparsers.add_parser('convert_file', help='Transpile a single SQL file.')
    file_parser.add_argument("source_file", help="Source file.")
    file_parser.add_argument("destination_file", help="Destination file.")
    file_parser.add_argument("--source_dialect", choices=["bigquery", "postgres", "duckdb"], default='bigquery', help="SQL dialect to transpile.")
    file_parser.add_argument("--destination_dialect", choices=["postgres", "duckdb"], default='postgres', help="SQL dialect to transpile.")
    file_parser.set_defaults(func=transpile_file)
    
    folder_parser = subparsers.add_parser('convert_folder', help='Transpile all SQL files in a folder.')
    folder_parser.add_argument("source_folder", help="Source folder.")
    folder_parser.add_argument("destination_folder", help="Destination folder.")
    folder_parser.add_argument("--source_dialect", choices=["bigquery", "postgres", "duckdb"], default='bigquery', help="SQL dialect to transpile.")
    folder_parser.add_argument("--destination_dialect", choices=["bigquery", "postgres", "duckdb"], default="postgres", help="SQL dialect to transpile.")
    folder_parser.set_defaults(func=transpile_folder)

    compare_parser = subparsers.add_parser(
        'compare_concepts',
        help='Compare derived concepts across PostgreSQL and DuckDB.',
        description=compare_concepts.__doc__,
        formatter_class=RawDescriptionHelpFormatter,
    )
    compare_parser.add_argument("--pg", required=True, help="libpq connection string for PostgreSQL")
    compare_parser.add_argument("--duckdb", dest="duckdb_path", required=True, help="path to the DuckDB database file")
    compare_parser.add_argument("--schema", default="mimiciv_derived")
    compare_parser.add_argument("--rtol", type=float, default=1e-6, help="relative tolerance for numeric comparison")
    compare_parser.add_argument("--atol", type=float, default=1e-9, help="absolute tolerance for numeric comparison")
    compare_parser.add_argument("--ignore", default="", help="comma-separated tables to skip")
    compare_parser.set_defaults(func=compare_concepts)

    args = parser.parse_args()
    # pop func from args
    args = vars(args)
    func = args.pop("func", None)
    if func is None:
        parser.print_help()
        sys.exit(2)
    

    # if writing just to one file, log the file name
    if "destination_file" in args:
        logging.info("Writing to: %s", args["destination_file"])

    # func may return a process exit code (e.g. compare_concepts)
    # transpile helpers return None, which maps to a successful exit.
    sys.exit(func(**args) or 0)


if __name__ == '__main__':
    main()
