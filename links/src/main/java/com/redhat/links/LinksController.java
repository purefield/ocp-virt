package com.redhat.links;

import java.io.IOException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.List;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.http.HttpHost;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestClientBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
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
	@Value("${spring.elasticsearch.index}")
	private String elasticsearchIndex;

	@GetMapping("/")
	public String index(@RequestParam(name = "term", required = false, defaultValue = "Red Hat") String term)
			throws Exception {
		// Create a custom SSLContext with a SelfSignedCertificate trust manager
		SSLContext sslContext = SSLContext.getInstance("TLS");
		sslContext.init(null, new TrustManager[] { new SelfSignedCertificateTrustManager() }, null);

		List<String> results = new ArrayList<String>();
		RestClientBuilder builder = RestClient.builder(
				new HttpHost(elasticsearchHost, 443, "https"))
				.setHttpClientConfigCallback(httpClientBuilder -> httpClientBuilder
						.setSSLContext(sslContext)
						.setSSLHostnameVerifier(NoopHostnameVerifier.INSTANCE));
		RestClient restClient = builder.build();
		ElasticsearchTransport transport = new RestClientTransport(
				restClient, new JacksonJsonpMapper());
		ElasticsearchClient client = new ElasticsearchClient(transport);
		try {
			SearchResponse<Link> response = client.search(s -> s
					.index(elasticsearchIndex)
					.query(q -> q
							.match(t -> t
									.field("name")
									.query(term))),
					Link.class);
			Long resultsCount = response.hits().total().value();
			results.add(
					String.format("Found %d results", resultsCount));
			for (Hit<Link> hit : response.hits().hits()) {
				results.add(hit.source().toString());
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return String.format("Greetings from Spring Boot! Search %s yields %s", elasticsearchIndex,
				results);
	}

	private static class SelfSignedCertificateTrustManager implements X509TrustManager {
		@Override
		public void checkClientTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException {
		}

		@Override
		public void checkServerTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException {
		}

		@Override
		public X509Certificate[] getAcceptedIssuers() {
			return new X509Certificate[0];
		}
	}
}
