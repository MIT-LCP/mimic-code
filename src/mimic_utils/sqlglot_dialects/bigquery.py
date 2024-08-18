import sqlglot
import sqlglot.dialects.bigquery
from sqlglot import Expression, exp, select
from sqlglot.helper import seq_get

sqlglot.dialects.bigquery.BigQuery.Parser.FUNCTIONS["PARSE_DATETIME"] = lambda args: exp.StrToTime(
    this=seq_get(args, 1), format=seq_get(args, 0)
)
sqlglot.dialects.bigquery.BigQuery.Parser.FUNCTIONS["FORMAT_DATE"] = lambda args: exp.TimeToStr(
    this=seq_get(args, 1), format=seq_get(args, 0)
)
sqlglot.dialects.bigquery.BigQuery.Parser.STRICT_CAST = False
