import { selectRegimen, unselectRegimen } from "../actions";
import { Actions } from "../../constants";

describe("selectRegimen()", () => {
  it("selects regimen", () => {
    const action = selectRegimen("Regimen.0.0");
    expect(action).toEqual({
      payload: "Regimen.0.0",
      type: Actions.SELECT_REGIMEN
    });
  });

  it("crashes if malformed", () => {
    console.warn = jest.fn();
    expect(() => selectRegimen("wrong")).toThrowError();
  });
});

describe("unselectRegimen()", () => {
  it("deselects regimen", () => {
    expect(unselectRegimen()).toEqual({
      type: Actions.SELECT_REGIMEN, payload: undefined
    });
  });
});
