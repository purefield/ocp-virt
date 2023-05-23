package com.example.application.views.list;

public class Entry {

    private String date;
    private String message;
    private String data;
    private Integer bytes;
 
    public Entry() {
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public Integer getBytes() {
        return bytes;
    }

    public void setBytes(Integer bytes) {
        this.bytes = bytes;
    }
}
