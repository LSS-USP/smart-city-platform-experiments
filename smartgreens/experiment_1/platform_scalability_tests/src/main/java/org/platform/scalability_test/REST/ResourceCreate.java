package org.platform.scalability_test.REST;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.JsonNode;
import org.platform.scalability_test.strategy.RESTStrategy;

public class ResourceCreate extends RESTStrategy {

	private String resourceUUID;
	HashMap<String, Object> resource;

	@Override
	public String beforeRequest() throws Exception {
		resource = new HashMap<String, Object>();
		resource.put("lat", (double) -23.559616);
		resource.put("lon", (double) -46.932386);
		resource.put("status", (String) "active");
		resource.put("description", (String) "none");

		String[] capabilities = {"temperature"};
		resource.put("capabilities", capabilities);
		return null;
	}

	@Override
	public String request(String saveRepository) throws Exception {
		HashMap<String, HashMap<String, Object>> parameters = new HashMap<String, HashMap<String, Object>>();
		parameters.put("data", resource);
		JSONObject jsonBody = new JSONObject(parameters);
		HttpResponse<JsonNode> response = post(buildUrl(RESOURCE_PATH), jsonBody);
		resourceUUID = ((JSONObject) (response.getBody().getObject().get("data"))).get("uuid").toString();
		return resourceUUID;
	}

	@Override
	public void afterRequest(String requestRepositoryResponse) throws Exception {
		delete(buildUrl(RESOURCE_PATH + "/" + resourceUUID));
	}

	@Override
	public void configure(Map<Object, Object> options) {
		configure(options, "resource-adaptor");
	}

}
