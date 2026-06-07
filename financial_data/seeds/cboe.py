import csv
import json
from pathlib import Path

SEED_DIR = Path(__file__).parent
JSON_PATH = SEED_DIR / "cboe.json"
CSV_PATH = SEED_DIR / "raw_cboe.csv"


def main() -> None:
    with JSON_PATH.open() as f:
        data = json.load(f)

    series = data["c:80896"]["series"][0]

    with CSV_PATH.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["date", "equity_put_call_ratio"])
        writer.writerows(series)

    print(f"Wrote {len(series)} rows to {CSV_PATH.name}")


if __name__ == "__main__":
    main()
