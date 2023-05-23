package com.redhat.links;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class LinksController {

	@GetMapping("/")
	public String index() {
		return "Greetings from Spring Boot!";
	}

}
