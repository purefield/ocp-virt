package com.example.application.views.list;

import java.util.Arrays;
import java.util.List;

import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.springframework.beans.factory.annotation.Value;

import com.example.application.views.MainLayout;
import com.vaadin.flow.component.grid.Grid;
import com.vaadin.flow.component.grid.GridVariant;
import com.vaadin.flow.component.html.Div;
import com.vaadin.flow.component.html.Span;
import com.vaadin.flow.component.icon.Icon;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.router.AfterNavigationEvent;
import com.vaadin.flow.router.AfterNavigationObserver;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import com.vaadin.flow.router.RouteAlias;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import jakarta.annotation.security.PermitAll;

@PageTitle("List")
@Route(value = "list", layout = MainLayout.class)
@RouteAlias(value = "", layout = MainLayout.class)
@PermitAll
public class ListView extends Div implements AfterNavigationObserver {
        @Value("${spring.elasticsearch.uris}")
        private String elasticsearchHost;
        @Value("${spring.elasticsearch.index}")
        private String elasticsearchIndex;

        Grid<Entry> grid = new Grid<>();

        public ListView() {
                addClassName("list-view");
                setSizeFull();
                grid.setHeight("100%");
                grid.addThemeVariants(GridVariant.LUMO_NO_BORDER, GridVariant.LUMO_NO_ROW_BORDERS);
                grid.addComponentColumn(entry -> createCard(entry));
                add(grid);
        }

        private HorizontalLayout createCard(Entry entry) {
                VerticalLayout description = new VerticalLayout();
                description.addClassName("description");
                description.setSpacing(false);
                description.setPadding(false);

                HorizontalLayout card = new HorizontalLayout();
                card.addClassName("card");
                card.setSpacing(false);
                card.getThemeList().add("spacing-s");

                HorizontalLayout header = new HorizontalLayout();
                header.addClassName("header");
                header.setSpacing(false);
                header.getThemeList().add("spacing-s");

                Span message = new Span(entry.getMessage());
                message.addClassName("message");
                Span date = new Span(entry.getDate());
                date.addClassName("date");
                header.add(message, date);

                Span data = new Span(entry.getData());
                data.addClassName("data");

                HorizontalLayout actions = new HorizontalLayout();
                actions.addClassName("actions");
                actions.setSpacing(false);
                actions.getThemeList().add("spacing-s");

                Icon bytesIcon = VaadinIcon.ABACUS.create();
                bytesIcon.addClassName("icon");
                Span bytes = new Span(Integer.toString(entry.getBytes()));
                bytes.addClassName("bytes");

                actions.add(bytesIcon, bytes);

                description.add(header, data, actions);
                card.add(description);
                return card;
        }

        @Override
        public void afterNavigation(AfterNavigationEvent event) {
                try {
                        RestClient restClient = RestClient.builder(
                                        new HttpHost(elasticsearchHost)).build();
                        ElasticsearchTransport transport = new RestClientTransport(
                                        restClient, new JacksonJsonpMapper());
                        ElasticsearchClient client = new ElasticsearchClient(transport);
                        SearchResponse<EntryDocument> search = client.search(s -> s
                                        .index(elasticsearchIndex)
                                        .query(q -> q
                                                        .term(t -> t
                                                                        .field("name")
                                                                        .value(v -> v.stringValue("openshift")))),
                                        EntryDocument.class);

                        for (Hit<EntryDocument> hit : search.hits().hits()) {
                                // createEntry(hit.source());
                        }
                } catch (Exception e) {
                        // TODO: handle exception
                }
                // Set some data when this view is displayed.
                List<Entry> entries = Arrays.asList( //
                                createEntry("date", "message", "data", 100));

                grid.setItems(entries);
        }

        private static Entry createEntry(String date, String message, String data, Integer bytes) {
                Entry e = new Entry();
                e.setMessage(message);
                e.setData(data);
                e.setDate(date);
                e.setBytes(bytes);

                return e;
        }

}
