let
    Source = Csv.Document(File.Contents("data\raw\mock_data.csv"),[Delimiter=",", Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Kept First Rows" = Table.FirstN(Source,1),
    #"Transposed Table" = Table.Transpose(#"Kept First Rows"),
    #"Renamed Columns" = Table.RenameColumns(#"Transposed Table",{{"Column1", "ColumnNames"}}),
    #"Inserted Merged Column" = Table.AddColumn(#"Renamed Columns", "ForUpdates", each Text.Combine({"Target.", [ColumnNames], " = Source.", [ColumnNames], ","}), type text),
    #"Inserted Merged Column1" = Table.AddColumn(#"Inserted Merged Column", "ForInserts", each Text.Combine({[ColumnNames], ","}), type text),
    #"Inserted Merged Column2" = Table.AddColumn(#"Inserted Merged Column1", "ForValues", each Text.Combine({"Source.", [ColumnNames], ","}), type text),
    #"Changed Type" = Table.TransformColumnTypes(#"Inserted Merged Column2",{{"ColumnNames", type text}})
in
    #"Changed Type"