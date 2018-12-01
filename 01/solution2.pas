program Solution2;

uses
    SysUtils;

const
    FILE_NAME = 'input.txt';

type
    TArray = Array of Int32;

    NodePtr = ^TNode;
    TNode = Record
        element: Int32;
        right: NodePtr;
        left: NodePtr
    end;

function TryInsertElement(var first: NodePtr; element: Int32): boolean;
{ Tries to insert an element into the tree. Returns true if the element already exists.}
var
    tmp: NodePtr;
begin
    if first = nil then
    begin
        New(tmp);
        tmp^.element := element;
        tmp^.right := nil;
        tmp^.left := nil;

        first := tmp;

        TryInsertElement := true;
    end
    else if first^.element = element then
        TryInsertElement := false
    else if first^.element > element then
        TryInsertElement := TryInsertElement(first.left, element)
    else
        TryInsertElement := TryInsertElement(first.left, element);
end; {TryInsertElement}

procedure DisposeTree(var ptr: NodePtr);
{ Disposes of the entire tree. }
begin
    if ptr^.right <> nil then
        DisposeTree(ptr^.right);
    if ptr^.left <> nil then
        DisposeTree(ptr^.left);

    dispose(ptr);
    ptr := nil;
end; {DisposeList}

function ReadNumbers(): TArray;
{ Reads all numbers in the file into an array. }
var
    arr: TArray;
    f: TextFile;
    {1 sign 10 digits, 1 safety}
    line: String[12];
    i, element: Int32;
begin
    SetLength(arr, 128);
    i := 0;

    AssignFile(f, FILE_NAME);
    Reset(f);

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

        arr[i] := element;
        inc(i);
        if (i >= Length(arr)) then
            SetLength(arr, i * 2)
    end;

    SetLength(arr, i - 1);

    ReadNumbers := arr;
end; {ReadNumbers}

var
    arr: TArray;
    first: NodePtr = nil;
    acc: Int32;
    i: Int32;
    done: Boolean = false;
begin
    arr := ReadNumbers();
    acc := 0;

    repeat
        for i := 0 to Length(arr) do
        begin
            acc := acc + arr[i];

            if not TryInsertElement(first, acc) then
            begin
                done := true;
                break;
            end;
        end;
    until done;

    WriteLn(acc);

    SetLength(arr, 0);
    DisposeTree(first);
end.
