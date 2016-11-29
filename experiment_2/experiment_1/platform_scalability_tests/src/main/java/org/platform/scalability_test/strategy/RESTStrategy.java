package org.platform.scalability_test.strategy;

import java.util.List;
import java.util.Map;

import org.json.JSONObject;

import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.JsonNode;
import com.mashape.unirest.http.Unirest;

public abstract class RESTStrategy implements Strategy<String>{

	protected final String RESOURCE_PATH = "components";
	protected final String DATA_PATH = "data";

	protected List<String> urls;
	protected String basePath;
	protected int currentUrlIndex;

	public void configure(Map<Object, Object> options, String serviceKey) {
		Map<Object, Object> serviceOptions = (Map<Object, Object>)options.get(serviceKey);
		urls = (List<String>)serviceOptions.get("base_uris");
		basePath = (String)serviceOptions.get("base_path");
		currentUrlIndex = 0;
	}

	public String getCurrentUrl() {
		return urls.get(currentUrlIndex);
	}

	public String buildUrl(String path) {
		return getCurrentUrl() + basePath + path;
	}

	public void changeToNextUrl() {
		++currentUrlIndex;
		if(currentUrlIndex >= urls.size()) {
			// TODO: blow up
		}
	}

	public void beforeExperiment() throws Exception {}

	public void beforeIteration() throws Exception {}

	public String beforeRequest() throws Exception {
		return null;
	}

	public abstract String request(String string) throws Exception;

	public void afterRequest(String requestResponse) throws Exception {}

	public void afterIteration() throws Exception {}

	public void afterExperiment() throws Exception {}

	public abstract void configure(Map<Object, Object> options);

	public HttpResponse<JsonNode> get(String url) throws Exception {
		return Unirest.get(url)
				.header("Content-Type", "application/json")
				.header("accept", "application/json")
				.asJson();
	}
	
	public HttpResponse<JsonNode> get(String url, String key, String queryString) throws Exception {
		return Unirest.get(url)
				.header("Content-Type", "application/json")
				.header("accept", "application/json")
				.queryString(key, queryString)
				.asJson();
	}

	public HttpResponse<JsonNode> post(String url, JSONObject body) throws Exception {
		return Unirest.post(url)
				.header("Content-Type", "application/json")
				.header("accept", "application/json")
				.body(body.toString())
				.asJson();
	}

	public HttpResponse<JsonNode> delete(String url) throws Exception {
		return Unirest.delete(url)
				.header("Content-Type", "application/json")
				.header("accept", "application/json")
				.asJson();
	}

	public HttpResponse<JsonNode> put(String url, JSONObject body) throws Exception {
		return Unirest.put(url)
				.header("Content-Type", "application/json")
				.header("accept", "application/json")
				.body(body.toString())
				.asJson();
	}
}