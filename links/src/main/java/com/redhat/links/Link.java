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

  /**
   * @param name
   * @param desc
   * @param url
   */
  public Link(String name, String desc, String url) {
    this.name = name;
    this.desc = desc;
    this.url = url;
  }

  public Link() {
  }

  @Field(type = Text, name = "desc")
  private String desc;

  @Field(type = Keyword, name = "url")
  private String url;

  @Override
  public String toString() {
    return "Link [id=" + id + ", name=" + name + ", desc=" + desc + ", url=" + url + "]";
  }

  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getDesc() {
    return desc;
  }

  public void setDesc(String desc) {
    this.desc = desc;
  }

  public String getUrl() {
    return url;
  }

  public void setUrl(String url) {
    this.url = url;
  }

}