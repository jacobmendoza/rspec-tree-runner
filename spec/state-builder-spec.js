/** @babel */
import StateBuilder from '../lib/state-builder';

describe('StateBuilder', () => {
  let sut;

  beforeEach(() => {
    sut = new StateBuilder();
  });

  it('can build a default state', () => {
    const result = sut.buildDefault();

    expect(result.file.name).toBe('');
    expect(result.file.isSpecFile()).toBeFalsy();
    expect(result.asTree).toEqual([]);
    expect(result.stdErrorData).not.toBeDefined();
    expect(result.summary).not.toBeDefined();
  });

  it('can build properly a new state', () => {
    const initialState = sut.buildDefault();

    const newState = sut
      .from(initialState)
      .withFile({name: 'some_name_spec.rb'})
      .withAsTree(['tree'])
      .withStdErrorData('error')
      .withSummary('summary')
      .loading(true)
      .build();

    expect(newState.file.name).toBe('some_name_spec.rb');
    expect(newState.asTree).toEqual(['tree']);
    expect(newState.stdErrorData).toBe('error');
    expect(newState.summary).toBe('summary');
    expect(newState.loading).toBeTruthy();
  });

  it('cleans previous error when building a new state', () => {
    const initialState = sut.buildDefault();

    const errorState = sut
      .from(initialState)
      .withSpecParsingError('error')
      .build();

    const newState = sut
      .from(errorState)
      .build();

    expect(newState.parsingSpecError).not.toBeDefined();
  });
});
