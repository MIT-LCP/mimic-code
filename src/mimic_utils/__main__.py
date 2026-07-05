from argparse import ArgumentParser
import logging

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

    args = parser.parse_args()
    # pop func from args
    args = vars(args)
    func = args.pop("func")

    # if writing just to one file, log the file name
    if "destination_file" in args:
        logging.info("Writing to: %s", args["destination_file"])
    func(**args)


if __name__ == '__main__':
    main()
