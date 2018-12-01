program solution1;

uses
    SysUtils;

const
    FILE_NAME = 'input.txt';

var
    f: textfile;
    line: string;
    acc, element: Int64;
begin
    AssignFile(f, FILE_NAME);
    Reset(f);

    acc := 0;

    while not eof(f) do
    begin
        ReadLn(f, line);

        element := StrToInt(
            Copy(
                line,
                2,
                Length(line) - 1
            )
        );

        if line[1] = '-' then
            element := -element;

        acc := acc + element;
    end;

    WriteLn(acc);
end.
