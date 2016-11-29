package org.platform.scalability_test.REST;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONObject;

import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.JsonNode;

import org.platform.scalability_test.strategy.RESTStrategy;

public class ResourceDataStream extends RESTStrategy {

	private String resourceUUID;
	HashMap<String, Object> resource;
	HashMap<String, Object> data;

	@Override
	public void beforeExperiment() throws Exception {
		resource = new HashMap<String, Object>();
		resource.put("lat", (double) -23.559616);
		resource.put("lon", (double) -46.932386);
		resource.put("status", (String) "active");
		resource.put("description", (String) "none");

		String[] capabilities = {"temperature"};
		resource.put("capabilities", capabilities);

		HashMap<String, HashMap<String, Object>> parameters = new HashMap<String, HashMap<String, Object>>();
		parameters.put("data", resource);
		JSONObject jsonBody = new JSONObject(parameters);
		HttpResponse<JsonNode> response = post(buildUrl(RESOURCE_PATH), jsonBody);
		resourceUUID = ((JSONObject) (response.getBody().getObject().get("data"))).get("uuid").toString();
		
		
		data = new HashMap<String, Object>();
		
		List<HashMap<String, String>> temperature = new ArrayList<HashMap<String, String>>();
		HashMap<String, String> value = new HashMap<String, String>();
		value.put("value","25.9");
		value.put("timestamp","20/08/2016T10:27:40");
		temperature.add(value);
		data.put("temperature", temperature);
	}

	@Override
	public String request(String string) throws Exception {
		HashMap<String, Object> parameters = new HashMap<String, Object>();		
		parameters.put("data", data);
		post(buildUrl(RESOURCE_PATH + "/" + resourceUUID + "/" + DATA_PATH), new JSONObject(parameters));
		return null;
	}
	
	@Override
	public void configure(Map<Object, Object> options) {
		configure(options, "resource-adaptor");
	}
}
