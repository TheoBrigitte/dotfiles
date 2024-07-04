def bbytes:
  def _bbytes(v; u):
    if (u | length) == 1 or (u[0] == "" and v < 10240) or v < 1024 then
      "\(v *100 | round /100) \(u[0])B"
    else
      _bbytes(v/1024; u[1:])
    end;
  _bbytes(.; ":Ki:Mi:Gi:Ti:Pi:Ei:Zi:Yi" / ":");

def bytes:
  def _bytes(v; u):
    if (u | length) == 1 or (u[0] == "" and v < 10000) or v < 1000 then
      "\(v *100 | round /100) \(u[0])B"
    else
      _bytes(v/1000; u[1:])
    end;
  _bytes(.; ":k:M:G:T:P:E:Z:Y" / ":");
