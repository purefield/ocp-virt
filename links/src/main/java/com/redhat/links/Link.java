package com.redhat.links;

import static org.springframework.data.elasticsearch.annotations.FieldType.Keyword;
import static org.springframework.data.elasticsearch.annotations.FieldType.Text;

import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;


@Document(indexName = "links")
public class Link {
  @Id
  private String id;
  
  @Field(type = Text, name = "name")
  private String name;
  
  @Field(type = Text, name = "desc")
  private String description;
  
  @Field(type = Keyword, name = "url")
  private String url;

}