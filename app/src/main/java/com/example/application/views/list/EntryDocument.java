package com.example.application.views.list;

import static org.springframework.data.elasticsearch.annotations.FieldType.Date;
import static org.springframework.data.elasticsearch.annotations.FieldType.Integer;
import static org.springframework.data.elasticsearch.annotations.FieldType.Text;

import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;

@Document(indexName = "generated")
public class EntryDocument {
    @Id
    private String id;

    @Field(type = Date, name = "date")
    private String name;

    @Field(type = Text, name = "message")
    private String message;

    @Field(type = Text, name = "data")
    private String data;

    @Field(type = Integer, name = "bytes")
    private String bytes;

}