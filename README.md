# Linear Step Indicator

LinearStepIndicator is a customizable and animated Flutter widget that visually represents progress through multiple steps or stages in a linear format. 
It is ideal for workflows, processes, or tracking milestones with smooth transitions between steps.

<br/>
<br/>
<img src="/decor/demo.gif" width="400" />

#### The package will be added to pub.dev a little later

Just add the package to your project's dependencies:

```yaml
  step_indicator:
    git:
      url: https://github.com/flyingV805/Flutter-LinearStepIndicator.git
```

## Usage

The widget needs to be passed an enumeration as a template.

You may also want to define the text and color of each stage. 
To do this, pass the appropriate maps to parameters `stagesNames` and `stagesColors`.

```dart
StagedLine<DemoStages>(
  stageState: _stage,
  stagesNames: const {
    DemoStages.created : 'created',
    DemoStages.precessed: 'precessed',
    DemoStages.sent: 'sent',
    DemoStages.completed: 'completed'
  },
  stagesColors: const {
    DemoStages.created : Colors.yellow,
    DemoStages.precessed: Colors.orange,
    DemoStages.sent: Colors.blue,
    DemoStages.completed: Colors.green
  },
),

```
