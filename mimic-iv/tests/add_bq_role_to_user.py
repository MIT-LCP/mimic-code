#!/usr/bin/env python
# coding: utf-8
import argparse
import json
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-f',
        '--file',
        type=str,
        required=True,
        help='Dataset to source the schema from.'
    )
    VALID_ROLES = ['READER', 'WRITER', 'OWNER']
    parser.add_argument(
        '-r',
        '--role',
        type=str,
        choices=VALID_ROLES,
        help=f"Role, one of: {', '.join(VALID_ROLES)}."
    )
    parser.add_argument(
        '-u',
        '--user',
        type=str,
        required=True,
        help='User to provide with permission.'
    )

    args = parser.parse_args()

    with open(args.file, 'r') as fp:
        data = json.load(fp)

    # verify user does not exist
    for d in data['access']:
        if 'userByEmail' in d:
            if d['userByEmail'] == args.user:
                sys.exit(f'User already exists in JSON as {d["role"]}.')

    access = {"role": args.role, "userByEmail": args.user}
    data['access'].append(access)

    with open(args.file, 'w') as fp:
        json.dump(data, fp)


if __name__ == '__main__':
    main()
