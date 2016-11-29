package org.platform.scalability_test.core;

import eu.choreos.vv.analysis.AggregatePerformance;
import eu.choreos.vv.analysis.ComposedAnalysis;
import eu.choreos.vv.chart.creator.MeanChartCreator;
import eu.choreos.vv.experiments.strategy.ExperimentStrategy;
import eu.choreos.vv.experiments.strategy.WorkloadScaling;
import org.platform.scalability_test.strategy.Strategy;

public class DegradationExperiment<T> extends PlatformExperiment<T> {
	public void setAttributes(TestConfiguration configuration, Strategy<T> subject) throws Exception {
		super.setAttributes(configuration, subject);
		configureExperiment();
	}

	private void configureExperiment() throws Exception {
		ExperimentStrategy experimentStrategy = new WorkloadScaling();
		this.setStrategy(experimentStrategy);
		this.setNumberOfRequestsPerStep(configuration.getRequestsPerStep());
		this.setNumberOfSteps(configuration.getNumberOfSteps());
		this.setAnalyser(new ComposedAnalysis(new AggregatePerformance("Aggregate Performance",
			new MeanChartCreator())));
		
		experimentStrategy.setParameterInitialValue(configuration.getInitialWorkloadValue());
		experimentStrategy.setFunction(configuration.getIncreaseWorkloadFunctionObject());
	}
}
