package com.redhat.links;

import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.rest_client.RestClientTransport;

@RestController
public class LinksController {
	@Value("${spring.elasticsearch.uris}")
	private String elasticsearchHost;

	@GetMapping("/")
	public String index() {
		try {
			RestClient restClient = RestClient.builder(
				new HttpHost(elasticsearchHost)).build();
				ElasticsearchTransport transport = new RestClientTransport(
				restClient, new JacksonJsonpMapper());
				ElasticsearchClient client = new ElasticsearchClient(transport);
				SearchResponse<Link> search = client.search(s -> s
				.index("links")
				.query(q -> q
					.term(t -> t
						.field("name")
						.value(v -> v.stringValue("openshift"))
					)),
					Link.class);
			
				for (Hit<Link> hit: search.hits().hits()) {
					// processLink(hit.source());
				}
				} catch (Exception e) {
			// TODO: handle exception
		}
		return "Greetings from Spring Boot!";
	}
    
}
