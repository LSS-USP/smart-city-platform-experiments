package org.platform.scalability_test;

import java.io.File;
import java.io.FileInputStream;
import java.util.Map;

import org.yaml.snakeyaml.Yaml;
import org.platform.scalability_test.core.PlatformExperiment;
import org.platform.scalability_test.core.TestConfiguration;
import org.platform.scalability_test.strategy.RESTStrategy;

public class App 
{
	private static final String SERVICES_CONFIG_YML = "services_configuration.yml";
	private static TestConfiguration testConfiguration;
	private static Map<Object, Object> serviceConfiguration;
	private static String architecture;

	public static void main(String[] args) throws Exception {
		serviceConfiguration = (Map<Object, Object>) new Yaml().load(new FileInputStream(new File(SERVICES_CONFIG_YML)));
		testConfiguration = new TestConfiguration(args[0]);

		Class<?> experimentClass = Class.forName("org.platform.scalability_test.core." + testConfiguration.getMetric() + "Experiment");

		RESTStrategy restStrategy = (RESTStrategy) initSubject(testConfiguration.getSubjectName()).newInstance();
		restStrategy.configure(serviceConfiguration);
		PlatformExperiment<String> experiment = (PlatformExperiment<String>) experimentClass.newInstance();
		experiment.setAttributes(testConfiguration, restStrategy);
		experiment.start();
	}

	private static Class<?> initSubject(String subjectName) throws ClassNotFoundException, InstantiationException, IllegalAccessException {
		return Class.forName("org.platform.scalability_test." + subjectName);
	}

}
