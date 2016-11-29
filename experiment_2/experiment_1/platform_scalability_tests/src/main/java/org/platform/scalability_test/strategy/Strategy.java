package org.platform.scalability_test.strategy;

import java.util.Map;

public interface Strategy<T> {
	//	Configuration method
	public void configure(Map<Object, Object> options, String serviceKey);

	// Resource management methods
	public String getCurrentUrl();

	public String buildUrl(String path);

	public void changeToNextUrl();

	// Experiment control methods
	public void beforeExperiment() throws Exception;

	public void beforeIteration() throws Exception;

	public T beforeRequest() throws Exception;

	public abstract T request(T item) throws Exception;

	public void afterRequest(T requestResponse) throws Exception;

	public void afterIteration() throws Exception;

	public void afterExperiment() throws Exception;
}