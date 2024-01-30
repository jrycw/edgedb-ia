from pathlib import Path

p = Path().cwd()
total_qry_file = p / "total_query.edgeql"

with open(total_qry_file, "w") as fw:
    for child in sorted(p.iterdir()):
        if child.is_dir():
            _internal_query = child / "_internal/query.edgeql"
            qry_file = child / "query.edgeql"
            if _internal_query.exists():
                with open(_internal_query) as fir, open(qry_file, "w") as fiw:
                    for line in fir:
                        if not line.startswith("#"):
                            fiw.write(line)
            if qry_file.exists():
                with open(qry_file) as fr:
                    fw.write(f"#================={str(child)[-2:]}=================\n")
                    fw.write(fr.read())
                    fw.write("\n" * 2)
